locals {
  tags = merge(var.tags, {
    Terraform_Module_Name       = "terraform-aws-remote-state-backend"
    Terraform_Module_Repository = "https://gitlab.com/tecracer-intern/terraform-landingzone/modules/terraform-aws-remote-state-backend.git"
  })
}
