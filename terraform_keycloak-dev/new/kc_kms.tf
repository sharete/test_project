### Data Key

resource "aws_kms_key" "keycloak" {
  count                   = var.stage == "prod" ? 1 : 0
  description             = "Keycloak Data ${local.common_prefix}"
  deletion_window_in_days = 10

  tags = local.tags
}

resource "aws_kms_alias" "keycloak" {
  count         = var.stage == "prod" ? 1 : 0
  name          = "alias/${local.common_prefix}-data"
  target_key_id = aws_kms_key.keycloak[0].key_id
}

resource "aws_kms_key" "keycloak_data" {
  count                   = var.stage != "prod" ? 1 : 0
  description             = "Keycloak Data ${local.common_prefix}"
  deletion_window_in_days = 10

  tags = local.tags
}

resource "aws_kms_alias" "keycloak_data" {
  count         = var.stage != "prod" ? 1 : 0
  name          = "alias/${local.common_prefix}-data"
  target_key_id = aws_kms_key.keycloak_data[0].key_id
}

### Config Key

resource "aws_kms_key" "keycloak_config" {
  description             = "Keycloak Config ${local.common_prefix}"
  deletion_window_in_days = 10

  tags = local.tags
}

resource "aws_kms_alias" "keycloak_config" {
  name          = "alias/${local.common_prefix}-config"
  target_key_id = aws_kms_key.keycloak_config.key_id
}

### Shared Secrets Key

resource "aws_kms_key" "keycloak_shared_secrets" {
  description             = "Keycloak Shared Secrets ${local.common_prefix}"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.keycloak_shared_secrets.json

  tags = local.tags
}

resource "aws_kms_alias" "keycloak_shared_secrets" {
  name          = "alias/${local.common_prefix}-shared-secrets"
  target_key_id = aws_kms_key.keycloak_shared_secrets.key_id
}

data "aws_iam_policy_document" "keycloak_shared_secrets" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid = "Allow use of the CMK"
    actions = [
      "kms:Decrypt",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.eu-central-1.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:SecretARN"

      # Example: arn:aws:secretsmanager:eu-central-1:608677983232:secret:ivv-keycloak-dev-vgh-ciam-dev-GPKa90
      values = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${local.common_prefix}-*"]
    }

    principals {
      type        = "AWS"
      identifiers = var.shared_secrets_users # User arn cross account
    }
  }
}

