output "s3_logging_bucket_id" {
  value = aws_s3_bucket.s3_logging_bucket.id
}

output "s3_logging_bucket" {
  value = aws_s3_bucket.s3_logging_bucket.bucket
}

# Output the CodeBuild IAM role
output "codebuild_iam_role_arn" {
  value = aws_iam_role.codebuild_iam_role.arn
}
