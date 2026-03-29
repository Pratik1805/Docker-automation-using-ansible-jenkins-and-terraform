resource "aws_key_pair" "docker_automation_keypair" {
  key_name   = "${var.env}-docker-automation-key"
  public_key = file("${path.root}/modules/ec2_instance/keys/keys.pub")
  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


resource "aws_security_group" "my_security_group" {
  name        = "${var.env}-docker-automation-sg"
  description = "This will add a TF generrated security group"
  vpc_id      = aws_default_vpc.default.id

  #inbound-rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }
  #outbound-rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access open outbound"
  }
  tags = {
    Name        = "${var.env}-docker-automation-sg"
    Environment = var.env
  }
}

resource "aws_instance" "my_instance" {
  ami             = var.ec2_ami__id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.docker_automation_keypair.key_name
  security_groups = [aws_security_group.my_security_group]

  depends_on = [aws_security_group.my_security_group, aws_key_pair.docker_automation_keypair]

  root_block_device {
    volume_size = var.ec2_instance_volume_size
    volume_type = "gp3"
  }
  tags = {
    Name        = "${var.ec2_instance_name}"
    Environment = "${var.env}"
  }

}