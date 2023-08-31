locals {
  tags = merge(var.tags, {
    Terraform = "true"
    System    = var.system
  })
}
