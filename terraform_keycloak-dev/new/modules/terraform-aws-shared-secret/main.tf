resource "aws_secretsmanager_secret" "secret" {
  description = "Shared Secret ${var.name}"
  kms_key_id  = var.kms_key_id
  name        = "${var.common_prefix}-${var.name}"
}

resource "aws_secretsmanager_secret_policy" "policy" {
  secret_arn = aws_secretsmanager_secret.secret.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Principal = { "AWS" = var.shared_secrets_users }
        Effect    = "Allow"
        Resource  = ["*"]
      }
    ]
  })
}
