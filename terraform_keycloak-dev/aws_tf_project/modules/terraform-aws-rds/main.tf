# DB resources

resource "random_integer" "int" {
  min = 1000
  max = 9999
}

locals {
  common_prefix = "${var.common_prefix}-${random_integer.int.id}"
  tags          = var.tags
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = var.cluster_identifier
  engine             = "aurora-postgresql"
  engine_version     = "13.8"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password

  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true

  backup_retention_period = 7
  preferred_backup_window = var.backup_window

  kms_key_id        = var.kms_key_id
  storage_encrypted = true

  iam_database_authentication_enabled = true

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [iam_database_authentication_enabled]
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                = var.cluster_size
  identifier           = "${aws_rds_cluster.main.cluster_identifier}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_db_subnet_group.main.name
  //performance_insights_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.common_prefix}-sng"
  subnet_ids = var.vpc_subnets
}

resource "aws_security_group" "main" {
  name        = "${local.common_prefix}-rds_sg"
  vpc_id      = var.vpc_id
  description = "Security Group for RDS traffic"

  ingress {
    description     = "Inbound Postgres from specific security groups only"
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = var.sg_ingress
    //cidr_blocks      = ["0.0.0.0/0"]
    //ipv6_cidr_blocks = ["::/0"]
  }

  // Allow all inbound, temp, Remove later!
  ingress {
    description = "Allow inbound traffic from ivv"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_ivv
    //ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description     = "Outbound traffic to specific security groups"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.sg_egress
    //cidr_blocks      = ["0.0.0.0/0"]
    //ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "rds-sg"
  })
}