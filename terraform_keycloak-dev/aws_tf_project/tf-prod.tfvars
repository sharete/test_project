region       = "eu-central-1"
system       = "keycloak"
organisation = "ivv"

stage = "prod"

vpc_id      = "vpc-03410424b6cc9659b"
vpc_subnets = ["subnet-0fac1047dba2d7bea", "subnet-06404b93c9bc38b33"]

zone_id = "Z04386092JESE7EX7736Q"

ecr_repo           = "352513567765.dkr.ecr.eu-central-1.amazonaws.com/ivv-keycloak-prod-repo"
log_retention_days = 90
cidr_ivv = ["193.111.219.0/24", # ivv Proxy
  "172.25.3.0/26",              # F5 BigIP
  "172.25.8.0/22",              # VGH Prod
  "172.25.44.0/22",             # OESA Prod
  "172.25.60.0/22",             # OEVO Prod
]
sso_profile = "ivv.keycloak.prod"

shared_secrets_users = [
  "arn:aws:iam::950045299113:user/ksp-prod-ci-user" # KSP Prod
]

shared_secrets_realms = [
  "vgh-ciam-prod",
  "oevo-ciam-prod",
  "oesa-ciam-prod",
  "vgh-ciam-prod-api",
  "oevo-ciam-prod-api",
  "oesa-ciam-prod-api"
]

# Tags
tags = {
} 