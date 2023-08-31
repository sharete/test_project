# Create the backend resources (S3 & DynamoDB)
module "backend" {
  source = "../modules/terraform-aws-remote-state-backend"

  organisation = var.organisation
  system       = var.system
  tags         = local.tags
}
