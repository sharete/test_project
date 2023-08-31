variable "region" {
  type        = string
  description = "Region of the Bootstrap Resources"
}

variable "s3_logging_bucket_name" {
  type        = string
  description = "Name of S3 bucket to use for access logging"
}

variable "tf_state_bucket_arn" {
  type        = string
  description = "ARN of the Terraform State S3 Bucket"
}

variable "tf_lock_table_arn" {
  type        = string
  description = "ARN of the Terraform State S3 Bucket"
}

/* CodeBuild Roles */
variable "codebuild_iam_role_name" {
  type        = string
  description = "Name for IAM Role utilized by CodeBuild"
}

variable "codebuild_iam_role_policy_name" {
  type        = string
  description = "Name for IAM policy used by CodeBuild"
}

variable "terraform_codecommit_repo_arn" {
  type        = string
  description = "Terraform CodeCommit git repo ARN"
}

variable "tf_codepipeline_artifact_bucket_arn" {
  type        = string
  description = "Codepipeline artifact bucket ARN"
}

variable "tags" {
  description = "Tags that should be applied to all Resources"
}
