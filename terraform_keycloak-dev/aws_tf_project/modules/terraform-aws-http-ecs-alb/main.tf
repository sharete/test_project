# Application Loadbalancer for Web Servers

resource "random_integer" "int" {
  min = 1000
  max = 9999
}

locals {
  common_prefix = "${var.common_prefix}-${random_integer.int.id}"
}

resource "aws_lb" "main" {
  name                       = "${local.common_prefix}-lb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-sg.id]
  subnets                    = var.vpc_subnets
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  tags = var.tags
}

resource "aws_lb_target_group" "main" {
  name        = "${local.common_prefix}-${var.target_port}"
  target_type = "ip"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    port     = var.target_port
    protocol = var.target_protocol
    interval = 60
    timeout  = 30
    matcher  = "200-399"
  }

  stickiness {
    enabled     = true
    type        = "app_cookie"
    cookie_name = "AUTH_SESSION_ID"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Listener for http
resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"

  # Redirect to HTTPS
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener for https
resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = aws_lb.main.id
  port              = "443"
  protocol          = "HTTPS"

  # https://aquasecurity.github.io/tfsec/v1.10.0/checks/aws/elb/use-secure-tls-policy/
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb-sg" {
  name   = "${local.common_prefix}-alb-sg"
  vpc_id = var.vpc_id

  /*
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
*/
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_ivv
    //ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS - Load Test"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.25.33.0/24"]
    //ipv6_cidr_blocks = ["::/0"]
  }

  /*
  ingress {
    description      = "f5 -- cg"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["172.25.3.0/26"]
    //ipv6_cidr_blocks = ["::/0"]
  }
  */

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.sg_egress // ECS Cluster
    //cidr_blocks      = ["0.0.0.0/0"]
    //ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "lb-sg"
  })
}

# DNS Record

data "aws_route53_zone" "selected" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "alb-dns" {
  zone_id = var.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
