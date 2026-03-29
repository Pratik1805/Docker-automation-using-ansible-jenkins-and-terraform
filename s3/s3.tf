resource "aws_s3_bucket" "automateBucket" {
  bucket = local.s3_bucket_name

  tags = {
    Name        = "${local.s3_bucket_name}"
    Environment = "${local.Environment}"
    project     = "${var.project_name}"
  }
}

resource "aws_s3_bucket_versioning" "automateBucket" {
  bucket = aws_s3_bucket.automateBucket.id

  versioning_configuration {
    status = "Enabled"
  }
}