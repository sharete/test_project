### EC2 - Auto Scaling Group

// https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier = var.vpc_subnets
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size

  target_group_arns = var.target_group_arns

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "OS"
    value               = "al2"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

data "aws_ami" "ecs_optimized" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }

  most_recent = true
  owners      = ["amazon"]
}

### EC2 - Launch Template

// Launch Templates
// https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template

resource "aws_launch_template" "this" {
  name_prefix   = "${local.common_prefix}-asg"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = var.user_data


  ### Block Device Mapping
  // https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = var.delete_on_termination
      encrypted             = true
      // kms_key_id = var.kms_key_id    // Erst aktivieren, wenn in IAM die passenden Berechtigungen vergeben wurden.
    }
  }
  /*
  dynamic "block_device_mappings" {
    for_each = var.ebs_block_device_to_value
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_type           = block_device_mappings.value.volume_type
        volume_size           = block_device_mappings.value.volume_size
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
      }
    }
  }
 */

  tags = local.tags

  tag_specifications {
    # Tags specific for resources launched by this template, in this case ec2 instances
    resource_type = "instance"

    tags = {
      Name = "${local.common_prefix}-ec2_instance"
    }
  }

}