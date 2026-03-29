resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "${var.project_name}-s3-backend"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-s3-backend"
    Environment = "${local.Environment}"
    project     = "${var.project_name}"
  }
}