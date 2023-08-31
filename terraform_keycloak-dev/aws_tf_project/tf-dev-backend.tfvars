# Backend config for test
region                  = "eu-central-1"
bucket                  = "ivv-keycloak-test-9127-state"
key                     = "keycloak-test.tfstate"
dynamodb_table          = "ivv-keycloak-test-9127-locktable"
encrypt                 = true
shared_credentials_file = "~/.aws/config"
profile                 = "ivv.keycloak.test"