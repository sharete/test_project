###########################
#--- S3 Backend Bucket ---#
###########################

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "${var.organisation}-${var.system}-${random_integer.random.id}-state"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle {
    prevent_destroy = false
  }

  tags = local.tags
}

resource "aws_s3_bucket_policy" "delete_protection" {
  bucket = aws_s3_bucket.terraform_bucket.id

  policy = templatefile("${path.module}/templates/s3_bucket_policy.tpl", {
    BUCKET_NAME = "${var.organisation}-${var.system}-${random_integer.random.id}-state"
  })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.terraform_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.delete_protection] # Otherwise sometimes you'll get: A conflicting conditional operation is currently in progress
}
