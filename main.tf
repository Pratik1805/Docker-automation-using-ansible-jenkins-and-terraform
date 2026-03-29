#-----------ec2 module-------------
module "ec2-dev" {
  source                   = "./modules/ec2_instance"
  ec2_instance_name        = var.ec2_instance_name
  ec2_ami__id              = var.ec2_ami__id
  ec2_instance_volume_size = var.ec2_instance_volume_size
  instance_type            = var.instance_type
  env                      = local.Environment

}
