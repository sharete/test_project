data "aws_route53_zone" "selected" {
  zone_id = var.zone_id
}

resource "tls_private_key" "key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "wildcard_cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "*.${data.aws_route53_zone.selected.name}"
    organization = "${var.common_prefix} Selfsigned"
  }

  validity_period_hours = 24 * 30

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "random_integer" "int" {
  min = 1000
  max = 9999
}

resource "aws_iam_server_certificate" "wildcard_cert" {
  name             = "${random_integer.int.id}-wildcard"
  certificate_body = tls_self_signed_cert.wildcard_cert.cert_pem
  private_key      = tls_private_key.key.private_key_pem
}
