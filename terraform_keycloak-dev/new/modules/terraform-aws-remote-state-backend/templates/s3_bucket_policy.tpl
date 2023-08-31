{
  "Statement": [
    {
      "Sid": "tf-state-bucket-delete-protection",
      "Action": [
        "s3:DeleteBucket"
      ],
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    },
    {
      "Sid": "AllowEncryptedRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
