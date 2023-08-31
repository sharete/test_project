### Caller identity
data "aws_caller_identity" "current" {}

### Shared Resources

resource "aws_acm_certificate" "pca_cert" {
  domain_name               = module.keycloak_lb.hostname
  certificate_authority_arn = "arn:aws:acm-pca:eu-central-1:308677999324:certificate-authority/89abcc20-57c3-40c3-8551-dcbb0684971e"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "pca_cert_san" {
  count                     = var.stage == "prod" ? 1 : 0
  domain_name               = module.keycloak_lb.hostname
  certificate_authority_arn = "arn:aws:acm-pca:eu-central-1:308677999324:certificate-authority/89abcc20-57c3-40c3-8551-dcbb0684971e"
  subject_alternative_names = ["anmeldung.vgh.de", "anmeldung.oesa.de", "anmeldung.oeffentlicheoldenburg.de"]
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${local.common_prefix}-ecs"

  tags = merge(local.tags, {
    Stage = var.stage
  })
}

### SMS messaging 
/*
resource "aws_sns_sms_preferences" "update_sms_prefs" {
  count               = var.stage == "prod" ? 1 : 0
  monthly_spend_limit = var.stage == "prod" ? 2500 : 100
  default_sms_type    = "Transactional"
}
*/

### Logging

resource "aws_cloudwatch_log_group" "log" {
  name              = local.common_prefix
  retention_in_days = var.log_retention_days

  tags = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "login_success" {
  name           = "LoginSuccess-${var.stage}"
  pattern        = "\"org.keycloak.events\" \"type=LOGIN,\""
  log_group_name = aws_cloudwatch_log_group.log.name

  metric_transformation {
    name      = "LoginSuccess-${var.stage}"
    namespace = "Keycloak-${var.stage}"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "login_failure" {
  name           = "LoginFailure-${var.stage}"
  pattern        = "\"org.keycloak.events\" \"type=LOGIN_ERROR,\""
  log_group_name = aws_cloudwatch_log_group.log.name

  metric_transformation {
    name      = "LoginFailure-${var.stage}"
    namespace = "Keycloak-${var.stage}"
    value     = "1"
  }
}

### Bucket für Cluster Discovery "s3ping"
resource "aws_s3_bucket" "s3ping" {
  bucket = "${local.common_prefix}-s3ping"

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "s3ping" {
  bucket = aws_s3_bucket.s3ping.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### Keycloak Resources

module "keycloak_lb" {
  source = "./modules/terraform-aws-http-ecs-alb"

  zone_id         = var.zone_id
  hostname        = "login-${var.stage}"
  certificate_arn = var.stage == "prod" ? aws_acm_certificate.pca_cert_san[0].arn : aws_acm_certificate.pca_cert.arn

  common_prefix = local.common_prefix
  vpc_id        = var.vpc_id
  vpc_subnets   = var.vpc_subnets
  cidr_ivv      = var.cidr_ivv
  sg_egress     = [module.keycloak_task.ecs]

  tags = local.tags

  target_port     = 8443
  target_protocol = "HTTPS"
}

### ECS

module "keycloak_task" {
  source = "./modules/terraform-aws-ecs-task-ec2"

  name  = "keycloak-${var.stage}-ec2"
  image = "${var.ecr_repo}/ivv-keycloak:${var.stage}"

  // Wichtig: Bestimmte Attribute dürfen nicht änderbar sein.
  // https://www.keycloak.org/docs/latest/server_admin/#_read_only_user_attributes
  command = [
    "start",
    "--log-level=INFO,org.keycloak.events:all", # Events are logged to console. Event recording in DB can thus be disabled.
    "--spi-user-profile-legacy-user-profile-read-only-attributes=attributes",
    "--https-key-store-file=/opt/keycloak/conf/server.keystore",
    "--spi-user-profile-declarative-user-profile-read-only-attributes=mobile_number,ivv-*",
    "--spi-truststore-file-file=/opt/keycloak/keystore/keycloak-truststore.jks",
    "--spi-truststore-file-password=123456",
    "--spi-truststore-file-hostname-verification-policy=WILDCARD",
    "--optimized"
  ]
  //command = ["start"]

  environment = {
    // https://www.keycloak.org/server/containers#_relevant_options
    KEYCLOAK_ADMIN = "admin"

    // https://www.keycloak.org/server/reverseproxy
    KC_PROXY = "reencrypt"

    // https://www.keycloak.org/server/all-config
    KC_FEATURES_DISABLED = "impersonation,account-api"

    // Notwendig für Betrieb im Produktionsmodus (https://www.keycloak.org/server/hostname)
    //KC_HOSTNAME = "anmeldung.vgh.de"
    KC_HOSTNAME_STRICT = "false"

    // DB
    KC_DB            = "postgres"
    KC_DB_URL        = "jdbc:postgresql://${module.keycloak_db.database_endpoint}:5432/keycloakdb${var.stage}"
    KC_DB_USERNAME   = "db_user"
    JAVA_OPTS_APPEND = "-Dkeycloak.password.blacklists.path=/opt/keycloak/password-blacklists -Djgroups.s3.region_name=eu-central-1 -Djgroups.s3.bucket_name=${aws_s3_bucket.s3ping.bucket}"
  }

  ### Security Groups
  http_port    = 8443
  cluster_port = 7800
  lb_sg        = module.keycloak_lb.lb_sg
  rds_sg       = module.keycloak_db.rds_group

  #additional_ingress_ports = [7800] // Keycloak Clustering

  enable_execute_command = false // Container are better accessed via EC2 Instance Connect

  desired_count = var.stage == "dev" ? 1 : 2
  #desired_count = 2 # Test des Keycloak Clusters in Dev (wg. Problemen in Test-Umgebung)

  common_prefix = local.common_prefix
  vpc_id        = var.vpc_id
  vpc_subnets   = var.vpc_subnets

  s3_bucket_ping = aws_s3_bucket.s3ping.bucket

  ### ECS Cluster
  cluster_id       = aws_ecs_cluster.main.id
  cluster_name     = aws_ecs_cluster.main.name
  target_group_arn = module.keycloak_lb.target_group_arn

  ### EC2 instance launch template

  # t2.medium supports max. 2 ENIs, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI
  # This can cause issues when a task definition is updated.
  # Possible fix: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-eni.html#eni-trunking-launching
  instance_type = "t2.large"
  user_data = base64encode(templatefile("./scripts/user_data.tpl", {
    ECS_CLUSTER = "${aws_ecs_cluster.main.name}"
  }))

  ### Block device mapping
  root_volume_type      = "gp2"
  root_volume_size      = 30
  delete_on_termination = true

  ### Autoscaling group
  min_size         = var.stage == "dev" ? 1 : 2
  desired_capacity = var.stage == "dev" ? 1 : 2

  # Test des Keycloak Clusters in Dev (wg. Problemen in Test-Umgebung)
  #min_size         =  2
  #desired_capacity =  2
  max_size = var.stage == "prod" ? 8 : 4

  ### Autoscaling policy
  /*
  enable_target_tracking_scaling = true
  target_tracking_metrics = "ASGAverageCPUUtilization"
  target_tracking_value = 50
  */

  ### Logging
  log_group = aws_cloudwatch_log_group.log.name

  kms_key_id = var.stage == "prod" ? aws_kms_key.keycloak[0].arn : aws_kms_key.keycloak_data[0].arn

  tags = local.tags

  # Inject secrets into env vars
  secrets = [
    {
      name      = "KEYCLOAK_ADMIN_PASSWORD"
      valueFrom = aws_secretsmanager_secret.keycloak_password.arn
    },
    {
      name      = "KC_DB_PASSWORD"
      valueFrom = aws_secretsmanager_secret.db_user_password.arn
    }
  ]
}

### Database

module "keycloak_db" {
  source = "./modules/terraform-aws-rds"

  common_prefix = local.common_prefix

  cluster_identifier = "keycloakdb-cluster-${var.stage}"

  database_name   = "keycloakdb${var.stage}"
  master_username = "db_admin"
  master_password = random_password.db_password.result

  postgres_port = 5432

  vpc_id      = var.vpc_id
  vpc_subnets = var.vpc_subnets
  sg_ingress  = [module.keycloak_task.ecs]
  sg_egress   = [module.keycloak_task.ecs]
  cidr_ivv    = var.cidr_ivv

  kms_key_id   = var.stage == "prod" ? aws_kms_key.keycloak[0].arn : aws_kms_key.keycloak_data[0].arn
  cluster_size = var.stage == "prod" ? 2 : 1

  backup_window = var.stage == "prod" ? "04:00-05:00" : "02:00-04:00"
}

### Supporting Fargate Resources (only or testing)
locals {
  fargate_tasks = [
    var.stage == "prod" ? null : {
      name  = "smtp-${var.stage}"
      image = "${var.ecr_repo}/gessnerfl-fake-smtp-server"
      environment = {
        SERVER_PORT                          = "80",
        FAKESMTP_PERSISTENCE_MAXNUMBEREMAILS = "1000" # Maximale Anzahl Mails in Inbox, alles darüber wird automatisch gelöscht
      }
      http_port                = 80
      additional_ingress_ports = [5025]
    },
    var.stage == "dev" ? {
      name  = "db-${var.stage}"
      image = "${var.ecr_repo}/pgadmin4"

      environment = {
        PGADMIN_DEFAULT_EMAIL    = "admin@pgadmin.test"
        PGADMIN_DEFAULT_PASSWORD = "pgadmintest"
        PGADMIN_DISABLE_POSTFIX  = "true"
      }
      http_port                = 80
      additional_ingress_ports = []
    } : null
  ]
}

module "fargate_tasks" {
  source   = "./modules/terraform-aws-ecs-task-fargate"
  for_each = { for task in local.fargate_tasks : task.name => task if task != null }

  name                     = each.value.name
  image                    = each.value.image
  environment              = each.value.environment
  http_port                = each.value.http_port
  enable_execute_command   = true
  common_prefix            = local.common_prefix
  vpc_id                   = var.vpc_id
  vpc_subnets              = var.vpc_subnets
  additional_ingress_ports = each.value.additional_ingress_ports
  cluster_id               = aws_ecs_cluster.main.id
  log_group                = aws_cloudwatch_log_group.log.name
  tags                     = local.tags
}
