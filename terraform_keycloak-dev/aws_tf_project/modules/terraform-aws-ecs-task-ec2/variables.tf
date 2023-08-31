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

variable "cluster_port" {
  type        = number
  description = "TCP Port of the cluster service of Keycloak."
  default     = 7800
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

variable "cluster_name" {
  type        = string
  description = "Name of the ECS Cluster."
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

variable "instance_type" {
  type        = string
  description = "Instance type for EC2 instance"
}

variable "desired_capacity" {
  type        = number
  description = "The number of Amazon EC2 instances that should be running in the group."
  default     = 1
}

variable "min_size" {
  type        = number
  description = "The minimum size of the Auto Scaling Group."
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the Auto Scaling Group."
  default     = 1
}

variable "target_group_arns" {
  type        = list(string)
  description = "A set of AWS Target Group ARNs, for use with Application or Network Load Balancing."
  default     = []
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance."
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume"
}

variable "root_volume_type" {
  type        = string
  description = "The type of volume. Can be standard, gp2, io1, sc1, or st1. Default: standard"
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination Default true."
  default     = true
}
/*
variable "ebs_block_device_to_value" {
  description = "The EBS volume"
}
*/

variable "target_tracking_value" {
  description = "Value for the metric that is the target value"
  type        = number
  default     = 30
}

variable "target_tracking_metrics" {
  description = "Name of the metric to be used. Defaults to"
  type        = string
  default     = "ASGAverageCPUUtilization"
}

variable "enable_target_tracking_scaling" {
  description = "Enable target tracking policy"
  type        = bool
  default     = false
}

variable "enable_simple_scaling" {
  description = "Enable simple scaling based on metric. Need to define thresholds for said metrics"
  type        = bool
  default     = false
}

variable "enable_scheduled_scaling" {
  description = "Enable scaling based on schedule"
  type        = bool
  default     = false
}

variable "scaling_threshold_high" {
  description = "Compare to this value in order to decide wether to scale up or not"
  type        = number
  default     = null
}

variable "scaling_threshold_low" {
  description = "Compare to this value in order to decide wether to scale down or not"
  type        = number
  default     = null
}

variable "evaluation_periods" {
  description = "Number of the most recent periods for the evaluation of the metric"
  type        = number
  default     = 2
}

variable "metric_period" {
  description = "How often to evaluate the metric in seconds"
  type        = number
  default     = 300
}

variable "scaling_cooldown_period_up" {
  description = "How much time before the next scaling event can occur"
  type        = number
  default     = 300
}

variable "scaling_cooldown_period_down" {
  description = "How much time before the next scaling event can occur"
  type        = number
  default     = 300
}

variable "scaling_instances_adjustment_up" {
  description = "Number of instances to add or to remove when scaling"
  type        = number
  default     = 1
}

variable "scaling_instances_adjustment_down" {
  description = "Number of instances to add or to remove when scaling"
  type        = number
  default     = -1
}

variable "scaling_metric_name" {
  description = "Name of the metric that decides the scaling"
  type        = string
  default     = "CPUUtilization"
}

variable "metric_namespace" {
  description = "Namespace of the metric"
  type        = string
  default     = "AWS/EC2"
}

variable "metric_statistic_type" {
  description = "Allowed values are: Average, Sum, Minimum, Maximum, SampleCount"
  type        = string
  default     = "Average"
}

variable "dimension_name" {
  description = "Name of the dimension of the metrics"
  type        = string
  default     = "AutoScalingGroupName"
}

variable "scheduled_scaling_min_size" {
  description = "Minimum size of the autoscaling group during scheduled scaling."
  type        = number
  default     = 0
}

variable "scheduled_scaling_max_size" {
  description = "Maximum size of the autoscaling group during scheduled scaling."
  type        = number
  default     = 1
}

variable "scheduled_scaling_desired_size" {
  description = "Desired size of the autoscaling group during scheduled scaling."
  type        = number
  default     = 1
}

variable "main_alarms" {
  description = ""
  type = map(object({
    alarm_name          = string
    alarm_description   = string
    namespace           = string
    metric_name         = string
    evaluation_periods  = number
    period              = number
    threshold           = number
    statistic           = string
    dimension_target    = string
    alarm_actions       = list(string)
    comparison_operator = string
  }))
  default = {}
}

variable "recurrence" {
  description = "Cronjob stlye definition of the schedule"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "KMS key for encryption of volumes"
  type        = string
}

variable "secrets" {
  type    = list(object({ valueFrom = string, name = string }))
  default = []
}

variable "s3_bucket_ping" {
  type        = string
  description = "S3 bucket name for keycloak cluster over s3-ping"
}

variable "lb_sg" {
  type = string
}

variable "rds_sg" {
  type = string
}