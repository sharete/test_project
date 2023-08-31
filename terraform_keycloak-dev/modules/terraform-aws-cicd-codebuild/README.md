# Terraform CI/CD CodeBuild

## Overview

This Module creates an a Terraform Plan and a Terraform Apply CodeBUild Project.

## Usage

````
module "cicd_codebuild" {
  source  = "git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-cicd-codebuild.git?ref=master"

  codebuild_project_terraform_plan_name         = "${var.organisation}-landingzone-codebuild-plan-tflz"
  codebuild_project_terraform_plan_description  = "Terraform Plan CodeBuild Project"
  codebuild_project_terraform_apply_name        = "${var.organisation}-landingzone-codebuild-apply-tflz"
  codebuild_project_terraform_apply_description = "Terraform Apply CodeBuild Project"
  codebuild_terraform_version                   = "0.15.0"
  s3_logging_bucket_id                          = module.bootstrap.s3_logging_bucket_id
  codebuild_iam_role_arn                        = module.bootstrap.codebuild_iam_role_arn
  s3_logging_bucket                             = module.bootstrap.s3_logging_bucket

  tags                                          = local.tags
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
| [aws_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| codebuild\_iam\_role\_arn | ARN of the CodeBuild IAM role | `any` | n/a | yes |
| codebuild\_project\_terraform\_apply\_description | Description for CodeBuild Terraform Apply Project | `any` | n/a | yes |
| codebuild\_project\_terraform\_apply\_name | Name for CodeBuild Terraform Apply Project | `any` | n/a | yes |
| codebuild\_project\_terraform\_plan\_description | Description for CodeBuild Terraform Plan Project | `any` | n/a | yes |
| codebuild\_project\_terraform\_plan\_name | Name for CodeBuild Terraform Plan Project | `any` | n/a | yes |
| codebuild\_terraform\_version | The Terraform Version needed for the CodeBuild Project | `string` | n/a | yes |
| s3\_logging\_bucket | Name of the S3 bucket for access logging | `any` | n/a | yes |
| s3\_logging\_bucket\_id | ID of the S3 bucket for access logging | `any` | n/a | yes |
| tags | Tags that should be applied to all Resources | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| codebuild\_terraform\_apply\_name | n/a |
| codebuild\_terraform\_plan\_name | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
