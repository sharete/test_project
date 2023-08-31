variable "database_name" {
  type        = string
  description = "Name of DB instance"
}

variable "master_username" {
  type        = string
  description = "Username for DB instance"
}

variable "master_password" {
  type        = string
  description = "Password for DB instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which resources placed."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets in which resources are placed."
}

variable "sg_ingress" {
  type        = list(string)
  description = "List of security groups for inbound traffic"
}

variable "sg_egress" {
  type        = list(string)
  description = "List of security groups for outbound traffic"
}

variable "postgres_port" {
  type        = number
  description = "Incoming port for postgres db"
}

variable "cluster_identifier" {
  type        = string
  description = "Incoming port for postgres db"
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

variable "kms_key_id" {
  type        = string
  description = "Key ID for database encryption"
}

variable "cluster_size" {
  type        = string
  description = "Number of nodes in the cluster"
}

variable "cidr_ivv" {
  type        = list(string)
  description = "CIDR range from ivv"
}

variable "backup_window" {
  type = string
}