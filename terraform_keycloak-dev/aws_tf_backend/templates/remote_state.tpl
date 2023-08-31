terraform {
  backend "s3" {
    region                  = "${region}"
    bucket                  = "${bucket}"
    key                     = "${key}"
    dynamodb_table          = "${dynamodb_table}"
    encrypt                 = ${encrypt}
    shared_credentials_file = "${sso_credentials_file}"
    profile                 = "${sso_profile_name}"
  }
}
