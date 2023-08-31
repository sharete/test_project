output "tf_state_s3_bucket_name" {
  description = "The Name of the Bucket."
  value       = module.backend.tf_state_s3_bucket_name
}

output "tf_state_dynamodb_name" {
  description = "The Name of the Table."
  value       = module.backend.tf_state_dynamodb_name
}
