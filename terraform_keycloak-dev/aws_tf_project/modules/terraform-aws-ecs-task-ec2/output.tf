//-- ASG (EC2)

/*
output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

//-- IAM

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "instance_profile" {
  value = aws_iam_instance_profile.this.name
}
*/
output "asg_arn" {
  value = aws_autoscaling_group.this.arn
}

output "ecs" {
  value = aws_security_group.ecs.id
}

output "ec2" {
  value = aws_security_group.ec2.id
}