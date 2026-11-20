terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source           = "./modules/network"
  name             = var.project_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "ec2" {
  source            = "./modules/ec2"
  name              = var.project_name
  instance_type     = var.instance_type
  public_key_path   = var.public_key_path
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.ec2_security_group_id
}

module "rds" {
  source             = "./modules/rds"
  name               = var.project_name
  private_subnet_ids = module.network.private_subnet_ids
  security_group_id  = module.network.rds_security_group_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}
