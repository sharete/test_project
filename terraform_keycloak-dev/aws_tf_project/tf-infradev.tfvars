region             = "eu-central-1"
system             = "keycloak"
organisation       = "ivv"
stage              = "infradev"
vpc_id             = "vpc-0623e14ae51e5f49d"
vpc_subnets        = ["subnet-06fea236df1f9ff5f", "subnet-00f1188745003e558", "subnet-03486e17523f36dfe"]
zone_id            = "Z01165152DDG6EULBBEM6"
ecr_repo           = "608677983232.dkr.ecr.eu-central-1.amazonaws.com/ivv-keycloak-test-repo"
log_retention_days = 7
cidr_ivv = [
  "193.111.219.0/24", # ivv Proxy
]
sso_profile = "ivv.keycloak.test"

shared_secrets_users = ["arn:aws:iam::831541922978:user/ksp-dev-ci-user"]

shared_secrets_realms = []

# Tags
tags = {
}

