variable "zone_id" {
  type        = string
  description = "Name of the zone for which the wildcard certificate should be created."
}

variable "validity" {
  type        = string
  description = "Validity period in hours."
  default     = 24 * 30
}

variable "common_prefix" {
  type        = string
  description = "Prefix for created AWS resources."
}