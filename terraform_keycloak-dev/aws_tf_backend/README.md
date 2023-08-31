# Terraform Backend

## Overview

This Folder contains the Terraform backend with an S3 Bucket and a DynamoDB Table for Terraform State information.
You can decide if you want the Backend state stored in the new backend, which is a bit redundant, but may be useful, or not... (use `use_remote_state = true/false`).
The TF Backend Config is automatically populated to folders that you specify via `populate_backend_to_folders`.

## Usage

- Use the AWS CLI to create a new local AWS SSO Profile for the AWS Account in your CLI: `aws configure sso --profile <client.Account.Stage>`
  - Make sure your User has the relevant Permissions to create/modify S3 Buckets and DynamoDB Tables
- Login to the new profile with: `aws sso login --profile <client.Account.Stage>`
- Customize your backend in the `terraform.auto.tfvars` file
  - Make sure you provide `sso_profile_name` and `sso_credentials_file`, `system` and `organisation`
- If still available, delete the `tf_backend.tf` file from this folder.
- Run `terraform init` and if that was successfull: `terraform apply`
- Your backend is now created.
- If you decided to use a remote state, run `tf init` again
  - Terraform will ask: "Do you want to copy existing state to the new backend?", accept with `yes`
  - You can delete `terraform.tfstate` and `terraform.tfstate.backup`
  - Your Backend is now initialized, you can proceed with the folder **aws_tf_project**

### Use the CI/CD Pipeline

If you want to use a CI/CD Pipeline with your project, your can do this by simply changing the variable `use_cicd_pipeline` to true.
This will create an AWS CodePipeline with:

- AWS CodeCommit Repository to store your Code
- AWS CodeBuild for Terraform Plan
- Manual approval step for the Plan
- AWS CodeBuild for Terraform Apply
- SNS Topic that notifies you about finished Plan
- S3 Bucket for Logs
- S3 Bucket for the Terraform Plans

As soon as you commit Code to the CodeCommit Repository, the CodePipeline will start running the plan and after approval the apply phase.

## Delete the Backend

If you did not use the `use_remote_state`, it's fairly easy.
With the AWS Management Console:

- go to the S3 Bucket, delete Bucket Policy (this is needed because it has Deletion Protection enabled)
- Empty the Bucket and all it's versions
- Use `terraform destroy`

If you used the remote state you may need to:

- Pull the remote state via `terraform state pull`
- Delete the `tf_backend.tf`

## Services used:

- Required:
  - AWS S3 Bucket
    - ACL: private
    - Encryption: AWS256
    - Versioning: Enabled
    - Deletion Protection Policy
    - Block Public Access Policy
  - DynamoDB:
    - Billing Mode: PAY_PER_REQUEST
    - Encryption: AWS owned CMK
- Optional:
  - CodePipeline
  - CodeCommit
  - CodeBuild

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.36.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend"></a> [backend](#module\_backend) | git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-remote-state-backend.git?ref=master |  |
| <a name="module_cicd_bootstrap"></a> [cicd\_bootstrap](#module\_cicd\_bootstrap) | git@gitlab.com:tecracer-intern/terraform-landingzone/modules/cicd/terraform-aws-cicd-bootstrap |  |
| <a name="module_cicd_codebuild"></a> [cicd\_codebuild](#module\_cicd\_codebuild) | git@gitlab.com:tecracer-intern/terraform-landingzone/modules/cicd/terraform-aws-cicd-codebuild |  |
| <a name="module_cicd_codecommit"></a> [cicd\_codecommit](#module\_cicd\_codecommit) | git@gitlab.com:tecracer-intern/terraform-landingzone/modules/cicd/terraform-aws-cicd-codecommit |  |
| <a name="module_cicd_codepipeline"></a> [cicd\_codepipeline](#module\_cicd\_codepipeline) | git@gitlab.com:tecracer-intern/terraform-landingzone/modules/cicd/terraform-aws-cicd-codepipeline |  |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic_subscription.sns-topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [local_file.create_remote_state](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.create_remote_state_in_populate_backend_to_folders](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organisation"></a> [organisation](#input\_organisation) | Name of the customer organisation (e.g. client name). | `string` | n/a | yes |
| <a name="input_populate_backend_to_folders"></a> [populate\_backend\_to\_folders](#input\_populate\_backend\_to\_folders) | A list with paths to the folders that should automatically receive a remote state configuration | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the TF Backend. | `string` | n/a | yes |
| <a name="input_sso_credentials_file"></a> [sso\_credentials\_file](#input\_sso\_credentials\_file) | The Credentials file that has the Profile information | `string` | `""` | no |
| <a name="input_sso_profile_name"></a> [sso\_profile\_name](#input\_sso\_profile\_name) | Name of the AWS Profile that is used for the Backend creation | `string` | `""` | no |
| <a name="input_system"></a> [system](#input\_system) | Name of a dedicated system or application (e.g. landingzone). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that should be applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_use_cicd_pipeline"></a> [use\_cicd\_pipeline](#input\_use\_cicd\_pipeline) | If you want a CICD Pipeline for the Terraform Landingzone or not | `bool` | n/a | yes |
| <a name="input_use_remote_state"></a> [use\_remote\_state](#input\_use\_remote\_state) | If you want to store the state in a remote State (will be in the backend that is created by this project) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tf_state_dynamodb_name"></a> [tf\_state\_dynamodb\_name](#output\_tf\_state\_dynamodb\_name) | The Name of the Table. |
| <a name="output_tf_state_s3_bucket_name"></a> [tf\_state\_s3\_bucket\_name](#output\_tf\_state\_s3\_bucket\_name) | The Name of the Bucket. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
