# Terraform CI/CD CodePipeline

## Overview

This Module creates the actual AWS CodePipeline

## Usage

````
module "cicd_bootstrap" {
  source  = "git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-cicd-bootstrap.git?ref=master"

  organisation = <Organization>
  system       = <System>
  tags         = <Tags>
}
````

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codepipeline.tf_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.tf_codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.tf_codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.tf_codepipeline_artifact_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_sns_topic.codepipeline_manual_approval](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_terraform_apply_name"></a> [codebuild\_terraform\_apply\_name](#input\_codebuild\_terraform\_apply\_name) | Terraform apply codebuild project name | `any` | n/a | yes |
| <a name="input_codebuild_terraform_plan_name"></a> [codebuild\_terraform\_plan\_name](#input\_codebuild\_terraform\_plan\_name) | Terraform plan codebuild project name | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that should be applied to all Resources | `any` | n/a | yes |
| <a name="input_terraform_codecommit_repo_name"></a> [terraform\_codecommit\_repo\_name](#input\_terraform\_codecommit\_repo\_name) | Terraform CodeCommit repo name | `any` | n/a | yes |
| <a name="input_tf_codepipeline_artifact_bucket_name"></a> [tf\_codepipeline\_artifact\_bucket\_name](#input\_tf\_codepipeline\_artifact\_bucket\_name) | Name of the TF CodePipeline S3 bucket for artifacts | `any` | n/a | yes |
| <a name="input_tf_codepipeline_name"></a> [tf\_codepipeline\_name](#input\_tf\_codepipeline\_name) | Terraform CodePipeline Name | `any` | n/a | yes |
| <a name="input_tf_codepipeline_role_name"></a> [tf\_codepipeline\_role\_name](#input\_tf\_codepipeline\_role\_name) | Name of the Terraform CodePipeline IAM Role | `any` | n/a | yes |
| <a name="input_tf_codepipeline_role_policy_name"></a> [tf\_codepipeline\_role\_policy\_name](#input\_tf\_codepipeline\_role\_policy\_name) | Name of the Terraform IAM Role Policy | `any` | n/a | yes |
| <a name="input_tf_codepipeline_sns_name"></a> [tf\_codepipeline\_sns\_name](#input\_tf\_codepipeline\_sns\_name) | Name for the SNS Topic for manual approvals | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tf_codepipeline_artifact_bucket_arn"></a> [tf\_codepipeline\_artifact\_bucket\_arn](#output\_tf\_codepipeline\_artifact\_bucket\_arn) | n/a |
| <a name="output_tf_codepipeline_manual_approval_sns_topic_arn"></a> [tf\_codepipeline\_manual\_approval\_sns\_topic\_arn](#output\_tf\_codepipeline\_manual\_approval\_sns\_topic\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
