data "aws_caller_identity" "current" {}
locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.automateBucket.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.automateBucket.arn}/*"]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dyanmodb:DeleteItem"]
    resources = [aws_dynamodb_table.dynamodb-table.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.project_name}s3BackendPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role" "jenkins_terraform_role" {
  name = "${var.project_name}s3_Backend_Role"

  # Use jsonencode for cleaner, safer code
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          # This allows specific users or roles (like your Jenkins server) to use this role
          AWS = local.principal_arns
        }
      }
    ]
  })

  tags = {
    Environment = "${local.Environment}"
    project     = "${var.project_name}"
  }
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.jenkins_terraform_role.name
  policy_arn = aws_iam_policy.policy.arn
}