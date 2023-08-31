# Terraform CI/CD Bootstrap

## Overview

This Module creates an S3 Logging Bucket and some Roles needed for the CodePipeline

## Services created

- AWS S3 Bucket
  - ACL: private
  - Encryption: AWS256

## Usage

````
module "cicd_bootstrap" {
  source  = "git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-cicd-bootstrap.git?ref=master"

  region                              = var.region
  tf_state_bucket_arn                 = module.backend.tf_state_s3_bucket_arn
  tf_lock_table_arn                    = module.backend.tf_state_dynamodb_arn
  s3_logging_bucket_name              = "${var.organisation}-landingzone-codebuild-bucket-tflz"
  codebuild_iam_role_name             = "${var.organisation}-landingzone-codebuild-iam-role-tflz"
  codebuild_iam_role_policy_name      = "${var.organisation}-landingzone-codebuild-iam-policy-tflz"
  terraform_codecommit_repo_arn       = module.cicd_codecommit.terraform_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.cicd_codepipeline.tf_codepipeline_artifact_bucket_arn

  tags                                = local.tags
}
````

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| codebuild\_iam\_role\_name | Name for IAM Role utilized by CodeBuild | `string` | n/a | yes |
| codebuild\_iam\_role\_policy\_name | Name for IAM policy used by CodeBuild | `string` | n/a | yes |
| region | Region of the Bootstrap Resources | `string` | n/a | yes |
| s3\_logging\_bucket\_name | Name of S3 bucket to use for access logging | `string` | n/a | yes |
| tags | Tags that should be applied to all Resources | `any` | n/a | yes |
| terraform\_codecommit\_repo\_arn | Terraform CodeCommit git repo ARN | `string` | n/a | yes |
| tf\_codepipeline\_artifact\_bucket\_arn | Codepipeline artifact bucket ARN | `string` | n/a | yes |
| tf\_lock\_table\_arn | ARN of the Terraform State S3 Bucket | `string` | n/a | yes |
| tf\_state\_bucket\_arn | ARN of the Terraform State S3 Bucket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| codebuild\_iam\_role\_arn | Output the CodeBuild IAM role |
| s3\_logging\_bucket | n/a |
| s3\_logging\_bucket\_id | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
