variable "ec2_ami__id" {
  description = "This is the AMI ID for eec2  Instrance"
  type        = string
}
variable "instance_type" {
  description = "This is the type of ec2 instance"
  type        = string
}
variable "ec2_instance_name" {
  description = "This is the name of my ec2 instance"
  type        = string
}
variable "ec2_instance_volume_size" {
  description = "This is the volume size for my ec2 instance"
  type        = string
}

locals {
  region      = "ap-south-1"
  Environment = "dev"
}