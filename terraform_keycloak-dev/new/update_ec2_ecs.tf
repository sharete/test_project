// EventBridge 
module "eventbridge" {
  #source = "../../modules/eventbridge"
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.17.3"

  create_bus = false

  role_name = "update-ecs-ec2-${var.stage}-role"

  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = "cron(0 2 * * ? *)"
    }
  }

  targets = {
    crons = [
      {
        name = "update-ecs-ec2-${var.stage}-cron"
        arn  = module.lambda_update_ecs-ec2.lambda_function_arn
      }
    ]
  }
}


// Lambda
module "lambda_update_ecs-ec2" {
  #source = "../../modules/lambda"
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.16.0"

  function_name = "update-ecs-ec2-${var.stage}"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  create_package                          = false
  local_existing_package                  = "lambda/main.zip"
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    OneRule = {
      principal = "events.amazonaws.com"
    }
  }
  attach_policy = true

  policy = aws_iam_policy.lambda_update_ecs-ec2.arn

  timeout = 900 // Timeout in Sekunden, 15min

  environment_variables = {
    CLUSTER = "ivv-keycloak-${var.stage}-ecs"
  }

  cloudwatch_logs_retention_in_days = 30
}

resource "aws_iam_policy" "lambda_update_ecs-ec2" {
  name   = "${local.common_prefix}-lambda-update-ecs-ec2-policy"
  policy = data.aws_iam_policy_document.lambda_update_ecs-ec2.json
}

data "aws_iam_policy_document" "lambda_update_ecs-ec2" {
  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:::*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:::log-group:/aws/lambda/update-ecs-ec2-${var.stage}:*"
    ]
  }
  statement {
    actions = [
      "lambda:GetAccountSettings*"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ecs:*",
      "ec2:*",
      "autoscaling:*",
      "ssm:*"
    ]

    resources = [
      "*"
    ]
  }
}