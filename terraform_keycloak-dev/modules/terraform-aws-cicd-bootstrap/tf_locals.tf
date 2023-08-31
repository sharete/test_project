locals {
  tags_module = {
    Terraform               = true
    Terraform_Module        = "terraform-aws-cicd-bootstrap"
    Terraform_Module_Source = "https://gitlab.com/tecracer-intern/terraform-landingzone/modules/terraform-aws-cicd-bootstrap"
  }
  tags = merge(local.tags_module, var.tags)
}
