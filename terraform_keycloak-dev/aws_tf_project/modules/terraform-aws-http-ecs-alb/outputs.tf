output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "hostname" {
  value = aws_route53_record.alb-dns.name
}

output "lb_sg" {
  value = aws_security_group.alb-sg.id
}