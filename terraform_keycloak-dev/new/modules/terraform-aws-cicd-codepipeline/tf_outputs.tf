output "tf_codepipeline_artifact_bucket_arn" {
  value = aws_s3_bucket.tf_codepipeline_artifact_bucket.arn
}

output "tf_codepipeline_manual_approval_sns_topic_arn" {
  value = aws_sns_topic.codepipeline_manual_approval.arn
}
