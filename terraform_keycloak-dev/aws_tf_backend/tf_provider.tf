provider "aws" {
  region                  = var.region
  shared_credentials_file = var.sso_credentials_file
  profile                 = var.sso_profile_name
}
