output "arn" {
  description = "The `arn` of the key."
  value       = aws_kms_key.key.arn
}

output "id" {
  description = "The globally unique identifier for the key."
  value       = aws_kms_key.key.id
}

output "alias_arn" {
  description = "The `arn` of the key alias."
  value       = aws_kms_alias.key_alias.arn
}

output "alias_name" {
  description = "The name of the key alias."
  value       = aws_kms_alias.key_alias.name
}
