locals {
  common_prefix = "${var.organisation}-${var.system}-${var.stage}"
  tags = merge(var.tags, {
    Terraform = "true"
    System    = var.system
    Stage     = var.stage
  })
}
