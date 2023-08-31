# - General Setup - #
variable "region" {
  type        = string
  description = "Region for the TF Backend."
}

variable "organisation" {
  type        = string
  description = "Name of the customer organisation (e.g. client name)."
}

variable "system" {
  type        = string
  description = "Name of a dedicated system or application (e.g. landingzone)."
}

# - Backend - #
variable "sso_credentials_file" {
  type        = string
  description = "The Credentials file that has the Profile information"
  default     = ""
}

variable "sso_profile_name" {
  type        = string
  description = "Name of the AWS Profile that is used for the Backend creation"
  default     = ""
}

# - CICD - #
variable "use_cicd_pipeline" {
  type        = bool
  description = "If you want a CICD Pipeline for the Terraform Landingzone or not"
}

# - Other - #
variable "use_remote_state" {
  type        = bool
  description = "If you want to store the state in a remote State (will be in the backend that is created by this project)"
  default     = false
}

variable "populate_backend_to_folders" {
  type        = list(string)
  description = "A list with paths to the folders that should automatically receive a remote state configuration"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags that should be applied to all resources."
  default     = {}
}
