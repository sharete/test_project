variable "vpc_id" {
  type        = string
  description = "VPC ID in which resources placed."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets in which resources are placed."
}

variable "tags" {
  type        = map(string)
  description = "Tag that should be applied to all resources"
  default     = {}
}

variable "common_prefix" {
  type        = string
  description = "Prefix for created AWS resources."
}

variable "name" {
  type        = string
  description = "Unique name of the task."
}

variable "image" {
  type        = string
  description = "Path to the Docker image."
}

variable "command" {
  type        = list(string)
  description = "Command to execute."
  default     = null
}

variable "environment" {
  type        = map(string)
  description = "Environment variables."
}

variable "http_port" {
  type        = number
  description = "TCP Port of the container which provides a HTTP service."
}

variable "additional_ingress_ports" {
  type        = list(number)
  description = "Additional ports for which ingress should be allowed."
  default     = []
}

variable "cluster_id" {
  type        = string
  description = "ID of the ECS Cluster."
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group."
  default     = null
}

variable "enable_execute_command" {
  type        = bool
  description = "Whether remote command execution is allowed."
  default     = false
}

variable "log_group" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}