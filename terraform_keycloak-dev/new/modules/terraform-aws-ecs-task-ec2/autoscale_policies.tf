### Scaling policies and cloudwatch alarms

// https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy

### Target Tracking
// https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html

resource "aws_autoscaling_policy" "target_tracking" {
  count                  = var.enable_target_tracking_scaling ? 1 : 0
  name                   = "target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking_metrics
    }
    target_value = var.target_tracking_value
  }
}


### Simple Scaling
// https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html

resource "aws_autoscaling_policy" "simple_scaling_up" {
  count                  = var.enable_simple_scaling ? 1 : 0
  name                   = "simple-scaling-policy-up"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapicity"
  scaling_adjustment     = var.scaling_instances_adjustment_up
  policy_type            = "SimpleScaling"
  cooldown               = var.scaling_cooldown_period_up
}

resource "aws_autoscaling_policy" "simple_scaling_down" {
  count                  = var.enable_simple_scaling ? 1 : 0
  name                   = "simple-scaling-policy-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapicity"
  scaling_adjustment     = var.scaling_instances_adjustment_down
  policy_type            = "SimpleScaling"
  cooldown               = var.scaling_cooldown_period_down
}

### Create alarms for simple scaling
locals {
  alarms = {
    scale_up = {
      alarm_name          = format("%s-%s-high", var.name, lower(var.scaling_metric_name))
      alarm_description   = "If metric is above threshold, scale up."
      namespace           = var.metric_namespace
      metric_name         = var.scaling_metric_name
      evaluation_periods  = var.evaluation_periods
      period              = var.metric_period
      threshold           = var.scaling_threshold_high
      statistic           = var.metric_statistic_type
      dimension_target    = aws_autoscaling_group.this.name
      alarm_actions       = aws_autoscaling_policy.simple_scaling_up
      comparison_operator = "GreaterThanOrEqualToThreshold"
    },
    scale_down = {
      alarm_name          = format("%s-%s-low", var.name, lower(var.scaling_metric_name))
      alarm_description   = "If metric is below threshold, scale down."
      namespace           = var.metric_namespace
      metric_name         = var.scaling_metric_name
      evaluation_periods  = var.evaluation_periods
      period              = var.metric_period
      threshold           = var.scaling_threshold_low
      statistic           = var.metric_statistic_type
      dimension_target    = aws_autoscaling_group.this.name
      alarm_actions       = aws_autoscaling_policy.simple_scaling_down
      comparison_operator = "LessThanOrEqualToThreshold"
    }
  }
  main_alarms = var.enable_simple_scaling ? local.alarms : {}
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each            = local.main_alarms
  comparison_operator = each.value.comparison_operator
  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  threshold           = each.value.threshold
  dimensions          = { (var.dimension_name) = (each.value.dimension_target) }
  alarm_actions       = each.value.alarm_actions
}

### Scheduled Scaling
// https://docs.aws.amazon.com/autoscaling/ec2/userguide/schedule_time.html

resource "aws_autoscaling_schedule" "scaling" {
  count                  = var.enable_scheduled_scaling ? 1 : 0
  scheduled_action_name  = format("%s-scheduled-scaling", var.name)
  autoscaling_group_name = aws_autoscaling_group.this.name
  recurrence             = var.recurrence
}
