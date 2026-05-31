################################################################################
# Environnement : STAGING
# Description : Infrastructure de pré-production — instance t3.small,
#               SSH restreint, configuration proche de la prod.
################################################################################

locals {
  environment = "staging"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    Repository  = "github.com/${var.github_username}/terraform-aws-infra"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = local.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  subnet_public_cidr = var.subnet_public_cidr
  common_tags        = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project_name     = var.project_name
  environment      = local.environment
  vpc_id           = module.vpc.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
  common_tags      = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  project_name        = var.project_name
  environment         = local.environment
  instance_type       = var.instance_type
  subnet_id           = module.vpc.subnet_public_id
  security_group_id   = module.security.web_sg_id
  ssh_public_key_path = var.ssh_public_key_path
  root_volume_size    = var.root_volume_size
  cpu_alarm_threshold = var.cpu_alarm_threshold
  ebs_optimized       = var.ebs_optimized
  common_tags         = local.common_tags
}
