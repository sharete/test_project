// Main AWS Account
provider "aws" {
  region = var.region

  shared_credentials_file = "${sso_credentials_file}"
  profile                 = "${sso_profile_name}"
}
