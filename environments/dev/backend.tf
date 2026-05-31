################################################################################
# Backend S3 — Environnement DEV
# Le state Terraform est stocké dans S3 avec lock DynamoDB.
# Remplacer TON_BUCKET_NAME par le nom réel du bucket S3.
################################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "TON_BUCKET_NAME-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform-project"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform-project"

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Project   = "terraform-aws-infra"
    }
  }
}
