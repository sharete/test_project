### Shared Secrets

module "shared_secret" {
  source   = "./modules/terraform-aws-shared-secret"
  for_each = toset(var.shared_secrets_realms)

  name                 = each.key
  kms_key_id           = aws_kms_key.keycloak_shared_secrets.arn
  common_prefix        = local.common_prefix
  tags                 = local.tags
  shared_secrets_users = var.shared_secrets_users
}

### Database Admin
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  description = "Database Password ${local.common_prefix}"
  kms_key_id  = aws_kms_key.keycloak_config.arn
  name        = "${local.common_prefix}-db"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

### Database User
resource "random_password" "db_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret" "db_user_password" {
  description = "Database User Password ${local.common_prefix}"
  kms_key_id  = aws_kms_key.keycloak_config.arn
  name        = "${local.common_prefix}-db-user"
}

resource "aws_secretsmanager_secret_version" "db_user_password" {
  secret_id     = aws_secretsmanager_secret.db_user_password.id
  secret_string = random_password.db_user_password.result
}

### Keycloak Admin
resource "random_password" "keycloak_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret" "keycloak_password" {
  description = "Keycloak Admin Password ${local.common_prefix}"
  kms_key_id  = aws_kms_key.keycloak_config.arn
  name        = var.stage == "prod" ? "${local.common_prefix}-kcadmin-2" : "${local.common_prefix}-kcadmin"
}

resource "aws_secretsmanager_secret_version" "keycloak_password" {
  secret_id     = aws_secretsmanager_secret.keycloak_password.id
  secret_string = random_password.keycloak_password.result
}