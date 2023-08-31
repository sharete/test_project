variable "kms_key_id" {
  type = string
}

variable "name" {
  type = string
}

variable "common_prefix" {
  type        = string
  description = "Prefix for created AWS resources."
}

variable "tags" {
  type        = map(string)
  description = "Tag that should be applied to all resources"
  default     = {}
}

variable "shared_secrets_users" {
  type    = list(string)
  default = []
}