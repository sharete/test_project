resource "random_integer" "int" {
  min = 1000
  max = 9999
}

locals {
  common_prefix = "${var.common_prefix}-${random_integer.int.id}"
  tags          = var.tags
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

### Task Execution Role (für Host)

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_logging" {
  statement {
    actions = [
      // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
  # Access to stored secrets and KMS key, used for injection of secrets as env variables
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:eu-central-1:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:eu-central-1:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_policy" "ecs_logging" {
  name   = "${local.common_prefix}-ecs-logging-policy"
  policy = data.aws_iam_policy_document.ecs_logging.json
}

resource "aws_iam_role_policy_attachment" "ecs_logging" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = aws_iam_policy.ecs_logging.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs-role" {
  name               = "${local.common_prefix}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = local.tags
}

### Task Role (für Container)

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "sns:Publish", // SMS-Versand für MFA
    ]

    resources = ["*"]
  }
}

### Access to S3-Ping-Bucket
data "aws_iam_policy_document" "ecs_task_s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:List*",
      "s3:Get*",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_ping}",
      "arn:aws:s3:::${var.s3_bucket_ping}/*"
    ]
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${local.common_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = local.tags
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.common_prefix}-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task.json
}

resource "aws_iam_policy" "ecs_task_s3" {
  name   = "${local.common_prefix}-ecs-task-s3-policy"
  policy = data.aws_iam_policy_document.ecs_task_s3.json
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_s3.arn
}

### Cluster + Tasks

resource "aws_ecs_task_definition" "main" {
  skip_destroy             = true
  family                   = var.name
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = 3072
  execution_role_arn       = aws_iam_role.ecs-role.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode(
    [
      {
        "networkMode" = "awsvpc"
        "family"      = var.name
        "portMappings" = [
          {
            "containerPort" = var.http_port
            "protocol"      = "tcp"
          }
        ]
        "essential"   = true
        "name"        = var.name
        "image"       = var.image
        "command"     = var.command
        "environment" = [for key, value in var.environment : { "name" = key, "value" = value }]
        "logConfiguration" = {
          "logDriver" = "awslogs"
          "options" = {
            "awslogs-group"         = var.log_group
            "awslogs-region"        = "eu-central-1"
            "awslogs-stream-prefix" = var.name
            "awslogs-create-group"  = "true"
          }
        }
        "secrets" = var.secrets
      }
    ]
  )

  tags = local.tags
}

resource "aws_ecs_service" "main" {
  name                   = "${local.common_prefix}-ec2service"
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.desired_count
  launch_type            = "EC2"
  enable_execute_command = var.enable_execute_command
  #iam_role        = aws_iam_role.ecs-role.arn

  network_configuration {
    assign_public_ip = false

    security_groups = [
      #aws_security_group.ecs_group.id,
      aws_security_group.ecs.id
    ]

    subnets = var.vpc_subnets
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn == null ? [] : [1]
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.name
      container_port   = var.http_port
    }
  }
  /*


  depends_on = [
    aws_lb_listener.front_end_tls,
    aws_iam_role.ecs-role
  ]
*/
}

# Capacity Provider to launching additional EC2 instances if necessary
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "${local.common_prefix}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn
    #managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp" {
  cluster_name = var.cluster_name

  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
  }
}

resource "aws_security_group" "ecs" {
  name   = "${local.common_prefix}-ecs"
  vpc_id = data.aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "ecs-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ecs-from-lb" {
  security_group_id = aws_security_group.ecs.id

  from_port                    = var.http_port
  to_port                      = var.http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.lb_sg

  tags = {
    Name = "ecs-from-lb-ingress"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ecs-kc-cluster-ipv4" {
  security_group_id = aws_security_group.ecs.id

  from_port   = var.cluster_port
  to_port     = var.cluster_port
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-kccluster-ipv4-ingress"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ecs-kc-cluster-ipv6" {
  security_group_id = aws_security_group.ecs.id

  from_port   = var.cluster_port
  to_port     = var.cluster_port
  ip_protocol = "tcp"
  cidr_ipv6   = "::/0"

  tags = {
    Name = "ecs-kccluster-ipv6-ingress"
  }

}

resource "aws_vpc_security_group_egress_rule" "ecs-to-rds" {
  security_group_id = aws_security_group.ecs.id

  from_port                    = "-1"
  to_port                      = "-1"
  ip_protocol                  = "-1"
  referenced_security_group_id = var.rds_sg

  tags = {
    Name = "ecs-to-rds-egress"
  }

}

resource "aws_vpc_security_group_egress_rule" "ecs-to-ec2" {
  security_group_id = aws_security_group.ecs.id

  from_port                    = "-1"
  to_port                      = "-1"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.ec2.id

  tags = {
    Name = "ecs-to-ec2-egress"
  }

}

resource "aws_vpc_security_group_egress_rule" "ecs-to-lb" {
  security_group_id = aws_security_group.ecs.id

  from_port                    = "-1"
  to_port                      = "-1"
  ip_protocol                  = "-1"
  referenced_security_group_id = var.lb_sg

  tags = {
    Name = "ecs-to-lb-egress"
  }

}

# Ohne diese AllowAll-Regeln keine Verbindung zum S3-Bucket für Cluster-Ping
resource "aws_vpc_security_group_egress_rule" "ecs-to-all-ipv4" {
  security_group_id = aws_security_group.ecs.id

  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-to-all-ipv4-egress"
  }

}

# Ohne diese AllowAll-Regeln keine Verbindung zum S3-Bucket für Cluster-Ping
resource "aws_vpc_security_group_egress_rule" "ecs-to-all-ipv6" {
  security_group_id = aws_security_group.ecs.id

  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv6   = "::/0"

  tags = {
    Name = "ecs-to-all-ipv6-egress"
  }

}
/*
resource "aws_security_group" "ecs_group" {
  name   = "${local.common_prefix}-ecs-sg"
  vpc_id = data.aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.additional_ingress_ports
    iterator = port
    content {
      description      = "Inbound TCP Port ${port.value}"
      from_port        = port.value
      to_port          = port.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}
*/

