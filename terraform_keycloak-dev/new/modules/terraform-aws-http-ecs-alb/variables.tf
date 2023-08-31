variable "zone_id" {
  type        = string
  description = "Name of the DNS zone for which the wildcard certificate should be created."
}

variable "hostname" {
  type        = string
  description = "Hostname under which the Load Balancer is accessible."
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the certificate to use for TLS."
}

variable "common_prefix" {
  type        = string
  description = "Prefix for created AWS resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which resources placed."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets in which resources are placed."
}

variable "sg_egress" {
  type        = list(string)
  description = "List of Security Group IDs for outbound traffic from LB"
}

variable "cidr_ivv" {
  type        = list(string)
  description = "CIDR range from ivv for incoming traffic"
}

variable "tags" {
  type        = map(string)
  description = "Tag that should be applied to all resources"
  default     = {}
}

variable "target_port" {
  type        = number
  description = "TCP port of the destination."
}

variable "target_protocol" {
  type        = string
  description = "Protocol used by the target."
  default     = "HTTP"
}
