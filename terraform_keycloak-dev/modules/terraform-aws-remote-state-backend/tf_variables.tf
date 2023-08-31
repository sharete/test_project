variable "organisation" {
  type        = string
  description = "Name of the current organisation"
}
variable "system" {
  type        = string
  description = "Name of a dedicated system or application"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tag for all resources"
}
