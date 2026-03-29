locals {
  region         = "ap-south-1"
  Environment    = "dev"
  s3_bucket_name = "${var.project_name}-bucket"
}
variable "project_name" {
  type    = string
  default = "zerotouch-docker"
}
variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}