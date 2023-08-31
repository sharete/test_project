region       = "eu-central-1"
system       = "keycloak"
organisation = "ivv"

stage = "test"

vpc_id      = "vpc-0623e14ae51e5f49d"
vpc_subnets = ["subnet-06fea236df1f9ff5f", "subnet-00f1188745003e558", "subnet-03486e17523f36dfe"]

zone_id = "Z01165152DDG6EULBBEM6"

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
  "arn:aws:iam::671129743498:user/ksp-test-ci-user" # KSP Test
]

shared_secrets_realms = [
  "vgh-ciam-test",
  "oevo-ciam-test",
  "oesa-ciam-test",
  "pentest-ciam-test",
  "default-ciam-test",
  "vgh-ciam-dami",
  "oevo-ciam-dami",
  "oesa-ciam-dami",
  "pentest-ciam-dami",
  "vgh-ciam-inte",
  "oevo-ciam-inte",
  "oesa-ciam-inte",
  "vgh-ciam-qali",
  "oevo-ciam-qali",
  "oesa-ciam-qali",
  "pentest-ciam-qali",
  "vgh-ciam-inte-api",
  "oevo-ciam-inte-api",
  "oesa-ciam-inte-api",
  "vgh-ciam-dami-api",
  "oevo-ciam-dami-api",
  "oesa-ciam-dami-api",
  "vgh-ciam-qali-api",
  "oevo-ciam-qali-api",
  "oesa-ciam-qali-api",
  "vgh-ciam-test-api",
  "oevo-ciam-test-api",
  "oesa-ciam-test-api",
  "pentest-ciam-test-api"
]

# Tags
tags = {
}