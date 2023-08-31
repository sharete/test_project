resource "random_integer" "int" {
  min = 1000
  max = 9999
}

locals {
  common_prefix = "${var.common_prefix}-${random_integer.int.id}"
  tags          = var.tags
}

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
      "s3:*",
      "sns:Publish" // SMS-Versand für MFA
    ]

    resources = ["*"]
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

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

### Cluster + Tasks

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs-role.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode(
    [
      {
        "memory"      = 1024
        "networkMode" = "awsvpc"
        "cpu"         = 512
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
      }
    ]
  )

  tags = local.tags
}

resource "aws_ecs_service" "main" {
  name                   = "${local.common_prefix}-service"
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = var.enable_execute_command
  #iam_role        = aws_iam_role.ecs-role.arn

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.ecs_group.id,
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

resource "aws_security_group" "ecs_group" {
  name   = "${local.common_prefix}-sg"
  vpc_id = data.aws_vpc.main.id

  ingress {
    description      = "Inbound HTTP"
    from_port        = var.http_port
    to_port          = var.http_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = data.aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = ["rtb-0035de8876333814b", "rtb-0974e44bbce33a468", "rtb-047f154a180a7c0a8"]
#   tags              = local.tags
# }
