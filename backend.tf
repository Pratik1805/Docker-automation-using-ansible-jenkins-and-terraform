terraform {
  backend "s3" {
    bucket         = "zerotouch-docker-bucket"
    dynamodb_table = "zerotouch-docker-s3-backend"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    role_arn       = "arn:aws:iam::317287358018:role/zerotouch-dockers3_Backend_Role"
    encrypt        = true
  }
}