terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}

module "network" {
  source = "./modules/network"

  name = var.project_name
}

module "security" {
  source = "./modules/security"

  name     = var.project_name
  vpc_id   = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
}

locals {
  db_username = "bookadmin"
}

module "secrets" {
  source = "./modules/secrets"

  name        = var.project_name
  db_username = local.db_username
}

module "public_alb" {
  source = "./modules/alb"

  name              = "${var.project_name}-public"
  internal          = false
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.security.public_alb_security_group_id
  target_port       = 80
  health_check_path = "/"
}

module "internal_alb" {
  source = "./modules/alb"

  name              = "${var.project_name}-internal"
  internal          = true
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.app_subnet_ids
  security_group_id = module.security.internal_alb_security_group_id
  target_port       = 3001
  health_check_path = "/api/books"
}

module "database" {
  source = "./modules/database"

  name              = var.project_name
  db_name           = var.db_name
  instance_class    = var.db_instance_class
  db_subnet_ids     = module.network.db_subnet_ids
  security_group_id = module.security.db_security_group_id
  db_username       = local.db_username
  db_password       = module.secrets.db_password

  backup_retention_days = var.db_backup_retention_days
  skip_final_snapshot   = var.db_skip_final_snapshot
  deletion_protection   = var.db_deletion_protection
}

module "web_iam" {
  source = "./modules/iam"

  name        = "${var.project_name}-web"
  secret_arns = []
}

module "app_iam" {
  source = "./modules/iam"

  name = "${var.project_name}-app"
  secret_arns = [
    module.secrets.db_secret_arn,
    module.secrets.jwt_secret_arn,
  ]
}

module "web" {
  source = "./modules/web"

  name                  = var.project_name
  instance_type         = var.web_instance_type
  subnet_ids            = module.network.public_subnet_ids
  security_group_id     = module.security.web_security_group_id
  target_group_arn      = module.public_alb.target_group_arn
  instance_profile_name = module.web_iam.instance_profile_name
  internal_alb_dns      = module.internal_alb.dns_name
  public_alb_dns        = module.public_alb.dns_name
  vpc_resolver_ip       = cidrhost(module.network.vpc_cidr, 2)
  repo_url              = var.repo_url
}

module "app" {
  source = "./modules/app"

  name                  = var.project_name
  region                = var.region
  instance_type         = var.app_instance_type
  subnet_ids            = module.network.app_subnet_ids
  security_group_id     = module.security.app_security_group_id
  target_group_arn      = module.internal_alb.target_group_arn
  instance_profile_name = module.app_iam.instance_profile_name
  db_host               = module.database.writer_endpoint
  db_name               = var.db_name
  db_secret_arn         = module.secrets.db_secret_arn
  jwt_secret_arn        = module.secrets.jwt_secret_arn
  public_alb_dns        = module.public_alb.dns_name
  repo_url              = var.repo_url
}
