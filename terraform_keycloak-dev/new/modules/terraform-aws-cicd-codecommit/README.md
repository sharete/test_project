# Terraform CI/CD CodeCommit

## Overview

This Module creates a CodeCommit Repository

## Usage

````
module "cicd_codecommit" {
  source  = "git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-cicd-codecommit.git?ref=master"

  repository_name = "${var.organisation}-landingzone-codecommit-tflz"
  repository_description = "CodeCommit Repository for the AWS Terraform Landingzone"

  tags            = local.tags
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
| [aws_codecommit_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repository\_description | CodeBuild git repository description | `string` | n/a | yes |
| repository\_name | CodeBuild git repository name | `string` | n/a | yes |
| tags | Tags that should be applied to all Resources | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| terraform\_codecommit\_repo\_arn | n/a |
| terraform\_codecommit\_repo\_name | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
