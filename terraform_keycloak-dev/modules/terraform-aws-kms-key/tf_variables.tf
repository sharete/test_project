// Required for provider
variable "region" {
  type        = string
  description = "The region of the account"
}

variable "aws_organizations_account_resource" {
  type        = map
  description = "The complete resource that holds all information about the created aws_organization_account(s)"
}

// Organization specific tags
variable "organization" {
  type        = string
  description = "Complete name of the organisation"
}

variable "account_name" {
  type        = string
  description = "Name of the current account."
}

variable "system" {
  type        = string
  description = "Name of a dedicated system or application"
}

variable "stage" {
  type        = string
  description = "Name of a dedicated system or application"
}

// Tags
variable "tags" {
  type        = map(string)
  description = "Tag that should be applied to all resources."
  default     = {}
}

// Module specific variables
# Default
variable "key_usage" {
  description = "Specifies the intended use of the key."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "key_policy" {
  description = "A valid policy JSON document."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type        = number
  default     = 30
}

# Required
variable "alias_name" {
  description = "The display name of the alias. Do not include the word `alias` followed by a forward slash (`alias/`)."
  type        = string
}

variable "description" {
  description = "The description of the key as viewed in AWS console."
  type        = string
}
