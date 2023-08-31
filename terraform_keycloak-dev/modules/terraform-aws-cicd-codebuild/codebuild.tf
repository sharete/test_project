# Create CodeBuild Project for Terraform Plan
resource "aws_codebuild_project" "codebuild_project_terraform_plan" {
  name          = var.codebuild_project_terraform_plan_name
  description   = var.codebuild_project_terraform_plan_description
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.s3_logging_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.codebuild_terraform_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild_project_terraform"
      stream_name = "codebuild_project_terraform_plan"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_plan_name}/build-log-plan"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_plan.yml"
  }

  tags = local.tags
}

# Create CodeBuild Project for Terraform Apply
resource "aws_codebuild_project" "codebuild_project_terraform_apply" {
  name          = var.codebuild_project_terraform_apply_name
  description   = var.codebuild_project_terraform_apply_description
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.s3_logging_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.codebuild_terraform_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild_project_terraform"
      stream_name = "codebuild_project_terraform_apply"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_terraform_apply_name}/build-log-apply"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_apply.yml"
  }

  tags = local.tags
}
