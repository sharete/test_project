locals {
  tags_module = {
    Terraform               = true
    Terraform_Module        = "terraform-aws-kms-key"
    Terraform_Module_Source = "https://gitlab.com/tecracer-intern/terraform-landingzone/modules/terraform-aws-kms-key"
  }
  tags = merge(local.tags_module, var.tags)
}
