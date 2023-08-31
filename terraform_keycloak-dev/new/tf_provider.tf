// Main AWS Account
provider "aws" {
  region = var.region

  shared_credentials_files = ["~/.aws/config"]
  profile                  = var.sso_profile

  # Avoid long retry times (default is 25...)
  max_retries = 5

  default_tags {
    tags = {
      Stage     = var.stage
      Terraform = "true"
      System    = var.system
    }
  }

}
