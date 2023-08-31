## Build an S3 bucket and DynamoDB for Terraform state and locking
module "cicd_bootstrap" {
  count  = var.use_cicd_pipeline ? 1 : 0
  source = "../modules/terraform-aws-cicd-bootstrap"
  # Only if CICD is activated...

  region                              = var.region
  tf_state_bucket_arn                 = module.backend.tf_state_s3_bucket_arn
  tf_lock_table_arn                   = module.backend.tf_state_dynamodb_arn
  s3_logging_bucket_name              = "${var.organisation}-${var.system}-cicd-codebuild-bucket"
  codebuild_iam_role_name             = "${var.organisation}-${var.system}-codebuild-iam-role"
  codebuild_iam_role_policy_name      = "${var.organisation}-${var.system}-codebuild-iam-policy"
  terraform_codecommit_repo_arn       = module.cicd_codecommit[0].terraform_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.cicd_codepipeline[0].tf_codepipeline_artifact_bucket_arn

  tags = local.tags
}

## Build a CodeCommit git repo
module "cicd_codecommit" {
  count  = var.use_cicd_pipeline ? 1 : 0
  source = "../modules/terraform-aws-cicd-codecommit"
  # Only if CICD is activated...

  repository_name        = "${var.organisation}-${var.system}-codecommit"
  repository_description = "CodeCommit Repository for System: ${var.system}"

  tags = local.tags
}

## Build CodeBuild projects for Terraform Plan and Terraform Apply
module "cicd_codebuild" {
  count  = var.use_cicd_pipeline ? 1 : 0
  source = "../modules/terraform-aws-cicd-codebuild"
  # Only if CICD is activated...

  codebuild_project_terraform_plan_name         = "${var.organisation}-${var.system}-codebuild-plan"
  codebuild_project_terraform_plan_description  = "Terraform Plan CodeBuild Project"
  codebuild_project_terraform_apply_name        = "${var.organisation}-${var.system}-codebuild-apply"
  codebuild_project_terraform_apply_description = "Terraform Apply CodeBuild Project"
  codebuild_terraform_version                   = "0.15.0"
  s3_logging_bucket_id                          = module.cicd_bootstrap[0].s3_logging_bucket_id
  codebuild_iam_role_arn                        = module.cicd_bootstrap[0].codebuild_iam_role_arn
  s3_logging_bucket                             = module.cicd_bootstrap[0].s3_logging_bucket

  tags = local.tags
}

## Build a CodePipeline
module "cicd_codepipeline" {
  count  = var.use_cicd_pipeline ? 1 : 0
  source = "../modules/terraform-aws-cicd-codepipeline"
  # Only if CICD is activated...

  tf_codepipeline_name                 = "${var.organisation}-${var.system}-codepipeline"
  tf_codepipeline_artifact_bucket_name = "${var.organisation}-${var.system}-cicd-codepipeline-artifacts-bucket"
  tf_codepipeline_role_name            = "${var.organisation}-${var.system}-codepipeline-iam-role"
  tf_codepipeline_role_policy_name     = "${var.organisation}-${var.system}-codepipeline-iam-role"
  terraform_codecommit_repo_name       = module.cicd_codecommit[0].terraform_codecommit_repo_name
  codebuild_terraform_plan_name        = module.cicd_codebuild[0].codebuild_terraform_plan_name
  codebuild_terraform_apply_name       = module.cicd_codebuild[0].codebuild_terraform_apply_name
  tf_codepipeline_sns_name             = "${var.organisation}-${var.system}-codepipeline-manualapproval"

  tags = local.tags
}

resource "aws_sns_topic_subscription" "sns-topic" {
  count     = var.use_cicd_pipeline ? 1 : 0
  topic_arn = module.cicd_codepipeline[0].tf_codepipeline_manual_approval_sns_topic_arn
  protocol  = "email"
  endpoint  = "smoehn@tecracer.de"
}

# Create a remote State Files for the Project Folders
resource "local_file" "create_buildspec_plan" {
  count  = var.use_cicd_pipeline ? 1 : 0

  content = templatefile("${path.module}/templates/buildspec_plan.tpl", {})

  filename             = "../buildspec_terraform_plan.yml"
  file_permission      = "0755"
  directory_permission = "0755"
}



resource "local_file" "create_buildspec_apply" {
  count  = var.use_cicd_pipeline ? 1 : 0

  content = templatefile("${path.module}/templates/buildspec_apply.tpl", {})

  filename             = "../buildspec_terraform_apply.yml"
  file_permission      = "0755"
  directory_permission = "0755"
}

