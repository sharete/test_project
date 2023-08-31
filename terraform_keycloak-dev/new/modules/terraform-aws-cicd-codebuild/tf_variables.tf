variable "codebuild_project_terraform_plan_name" {
  description = "Name for CodeBuild Terraform Plan Project"
}

variable "codebuild_project_terraform_plan_description" {
  description = "Description for CodeBuild Terraform Plan Project"
}

variable "codebuild_project_terraform_apply_name" {
  description = "Name for CodeBuild Terraform Apply Project"
}

variable "codebuild_project_terraform_apply_description" {
  description = "Description for CodeBuild Terraform Apply Project"
}

variable "s3_logging_bucket_id" {
  description = "ID of the S3 bucket for access logging"
}

variable "s3_logging_bucket" {
  description = "Name of the S3 bucket for access logging"
}

variable "codebuild_iam_role_arn" {
  description = "ARN of the CodeBuild IAM role"
}

variable "codebuild_terraform_version" {
  type        = string
  description = "The Terraform Version needed for the CodeBuild Project"
}

variable "tags" {
  description = "Tags that should be applied to all Resources"
}
