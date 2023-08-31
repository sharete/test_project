#############################
#--- DynamoDB State Lock ---#
#############################

resource "aws_dynamodb_table" "terraform_dynamodb" {
  name         = "${var.organisation}-${var.system}-${random_integer.random.id}-locktable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}
