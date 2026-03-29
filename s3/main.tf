data "aws_region" "current_region" {}

resource "aws_resourcegroups_group" "automate_resource_group" {
  name = "${var.project_name}-s3-backend"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["${var.project_name}"]
    }
  ]
}
JSON
  }
}


output "config" {
  value = {
    bucket         = aws_s3_bucket.automateBucket.bucket
    region         = data.aws_region.current_region.name
    role_arn       = aws_iam_role.jenkins_terraform_role.arn
    dynamodb_table = aws_dynamodb_table.dynamodb-table.name
  }
}