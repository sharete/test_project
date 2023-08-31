# Terraform AWS Remote State Backend

## Overview

This Module create a Terraform Remote State Backend with S3 Bucket and DynamoDB Table

## Usage

````
module "backend" {
  source  = "git@gitlab.com:tecracer-intern/terraform-landingzone/modules/terraform-aws-remote-state-backend.git?ref=0.0.1"

  organisation = <Organization>
  system       = <System>
  tags         = <Tags>
}
````

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13, < 0.14 |
| aws | >= 2.68, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.68, < 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organisation | Name of the current organisation | `string` | n/a | yes |
| system | Name of a dedicated system or application | `string` | n/a | yes |
| tags | Tag for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| tf\_state\_dynamodb\_name | n/a |
| tf\_state\_s3\_bucket\_name | n/a |
