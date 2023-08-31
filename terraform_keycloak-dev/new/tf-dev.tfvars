region             = "eu-central-1"
system             = "keycloak"
organisation       = "ivv"
stage              = "dev"
vpc_id             = "vpc-0623e14ae51e5f49d"
vpc_subnets        = ["subnet-06fea236df1f9ff5f", "subnet-00f1188745003e558", "subnet-03486e17523f36dfe"]
zone_id            = "Z01165152DDG6EULBBEM6"
ecr_repo           = "608677983232.dkr.ecr.eu-central-1.amazonaws.com/ivv-keycloak-test-repo"
log_retention_days = 7
cidr_ivv = [
  "193.111.219.0/24", # ivv Proxy
  "172.25.3.0/26",    # F5 BigIP
  "172.25.16.0/22",   # KSP Dev VGH
  "172.25.52.0/22",   # KSP Dev OESA
  "172.25.40.0/22",   # KSP Dev OEVO
  "172.25.12.0/22",   # KSP Test VGH
  "172.25.48.0/22",   # KSP Test OESA
  "172.25.36.0/22",   # KSP Test OEVO
  "172.25.56.0/22",   # KSP Test Pentest
]
sso_profile = "ivv.keycloak.test"

shared_secrets_users = [
  "arn:aws:iam::831541922978:user/ksp-dev-ci-user", # KSP Dev
]

shared_secrets_realms = [
  "vgh-ciam-dev",
  "oevo-ciam-dev",
  "oesa-ciam-dev",
  "pentest-ciam-dev",
  "default-ciam-dev",
  "vgh-ciam-dev-api",
  "oevo-ciam-dev-api",
  "oesa-ciam-dev-api"
]

# Tags
tags = {
}

