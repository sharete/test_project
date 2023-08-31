terraform {
  backend "s3" {
    region                  = "eu-central-1"
    bucket                  = "ivv-keycloak-test-9127-state"
    key                     = "backend.tfstate"
    dynamodb_table          = "ivv-keycloak-test-9127-locktable"
    encrypt                 = true
    shared_credentials_file = "~/.aws/config"
    profile                 = "ivv.keycloak.test"
  }
}
