# - General Setup - #
variable "organisation" {
  type        = string
  description = "Complete name of the organisation"
}

variable "system" {
  type        = string
  description = "Name of a dedicated system or application (e.g. landingzone)."
}

variable "region" {
  type        = string
  description = "Region for the TF Backend"
}

variable "tags" {
  type        = map(string)
  description = "Tag that should be applied to all resources"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which resources placed."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets in which resources are placed."
}

variable "cidr_ivv" {
  type        = list(string)
  description = "CIDR range from ivv"
}

variable "stage" {
  type        = string
  description = "Short name of the stage (dev/test/prod)."
}

variable "zone_id" {
  type        = string
  description = "ID of the Route 53 DNS zone in which resources are created."
}

variable "ecr_repo" {
  type        = string
  description = "Path of ECR Repo. Note: This repo is best generated outside of Terraform."
}

variable "log_retention_days" {
  type        = number
  description = "Number of days for which logs are stored."
}

variable "sso_profile" {
  type        = string
  default     = "ivv.keycloak.test"
  description = "Name of the AWS SSO profile to use."
}

variable "shared_secrets_users" {
  type        = list(string)
  default     = []
  description = "List of users from other accounts which can read the shared secrets."
}

variable "shared_secrets_realms" {
  type        = list(string)
  default     = []
  description = "List of realms for which shared secrets are created."
}