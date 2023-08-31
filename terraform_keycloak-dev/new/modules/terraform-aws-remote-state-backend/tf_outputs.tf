output "tf_state_s3_bucket_name" {
  value = aws_s3_bucket.terraform_bucket.bucket
}

output "tf_state_dynamodb_name" {
  value = aws_dynamodb_table.terraform_dynamodb.name
}

output "tf_state_s3_bucket_arn" {
  value = aws_s3_bucket.terraform_bucket.arn
}

output "tf_state_dynamodb_arn" {
  value = aws_dynamodb_table.terraform_dynamodb.arn
}
