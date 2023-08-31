region                  = "eu-central-1"
bucket                  = "ivv-keycloak-prod-1200-state"
key                     = "keycloak-prod.tfstate"
dynamodb_table          = "ivv-keycloak-prod-1200-locktable"
encrypt                 = true
shared_credentials_file = "~/.aws/config"
profile                 = "ivv.keycloak.prod"