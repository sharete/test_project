# Build an AWS S3 bucket for logging
resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = var.s3_logging_bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

# Create an IAM role for CodeBuild to assume
resource "aws_iam_role" "codebuild_iam_role" {
  name = var.codebuild_iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}


# Create an IAM role policy for CodeBuild to use implicitly
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  name = var.codebuild_iam_role_policy_name
  role = aws_iam_role.codebuild_iam_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllPermissions",
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


# Create IAM role for Terraform builder to assume
resource "aws_iam_role" "tf_iam_assumed_role" {
  name = "TerraformCodePipelineAssumedIamRole-tflz"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.codebuild_iam_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}


# Create broad IAM policy Terraform to use to build, modify resources
resource "aws_iam_policy" "tf_iam_assumed_policy" {
  name = "TerraformCodePipelineAssumedIamPolicy-tflz"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllPermissions",
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach IAM assume role to policy
resource "aws_iam_role_policy_attachment" "tf_iam_attach_assumed_role_to_permissions_policy" {
  role       = aws_iam_role.tf_iam_assumed_role.name
  policy_arn = aws_iam_policy.tf_iam_assumed_policy.arn
}
