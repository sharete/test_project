### EC2 IAM & SG

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2-role" {
  name               = "${local.common_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

data "aws_iam_policy" "ec2_container_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "ec2_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_container_role" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.ec2_container_role.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.ec2_ssm.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.common_prefix}-ec2-profile"
  role = aws_iam_role.ec2-role.name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2" {
  name   = "${local.common_prefix}-ec2"
  vpc_id = data.aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "ec2-sg"
  })

}

resource "aws_vpc_security_group_egress_rule" "ec2-to-ecs" {
  security_group_id = aws_security_group.ec2.id

  from_port                    = "-1"
  to_port                      = "-1"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.ecs.id

  tags = {
    Name = "ec2-to-ecs-egress"
  }

}

resource "aws_vpc_security_group_egress_rule" "ec2-to-all-ipv4" {
  security_group_id = aws_security_group.ec2.id

  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ec2-to-all-ipv4-egress"
  }

}

resource "aws_vpc_security_group_egress_rule" "ec2-to-all-ipv6" {
  security_group_id = aws_security_group.ec2.id

  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv6   = "::/0"

  tags = {
    Name = "ec2-to-all-ipv6-egress"
  }

}

/*
resource "aws_security_group" "ec2_group" {
  name   = "${local.common_prefix}-sg-ec2-instance"
  vpc_id = data.aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}
*/
