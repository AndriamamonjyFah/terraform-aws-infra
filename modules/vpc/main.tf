################################################################################
# Module : VPC
# Description : Crée un VPC complet avec subnet public, Internet Gateway,
#               Route Table, VPC Flow Logs (CloudWatch + KMS) et
#               restriction du default Security Group.
################################################################################

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
# VPC principal
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# CKV2_AWS_12 — Bloquer tout trafic sur le default Security Group du VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  # Aucune règle ingress/egress = tout bloqué par défaut

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-default-sg-RESTRICTED"
  })
}

################################################################################
# KMS — Clé pour chiffrement CloudWatch Logs (CKV_AWS_158)
################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "flow_log" {
  description             = "KMS key for VPC flow logs — ${var.project_name}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM Root Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-flow-log-kms"
  })
}

resource "aws_kms_alias" "flow_log" {
  name          = "alias/${var.project_name}-${var.environment}-flow-log"
  target_key_id = aws_kms_key.flow_log.key_id
}

################################################################################
# CKV2_AWS_11 — VPC Flow Logs → CloudWatch (chiffré KMS, rétention 1 an)
################################################################################

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flow-log/${var.project_name}-${var.environment}"
  retention_in_days = 365                      # CKV_AWS_338 — rétention >= 1 an
  kms_key_id        = aws_kms_key.flow_log.arn # CKV_AWS_158 — chiffrement KMS

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-flow-log-group"
  })
}

resource "aws_iam_role" "flow_log" {
  name = "${var.project_name}-${var.environment}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-flow-log-role"
  })
}

# CKV_AWS_290 + CKV_AWS_355 — IAM policy restrictive avec Resource ARN précis
resource "aws_iam_role_policy" "flow_log" {
  name = "${var.project_name}-${var.environment}-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        # Resource ciblé sur le log group exact — pas de wildcard *
        Resource = [
          aws_cloudwatch_log_group.flow_log.arn,
          "${aws_cloudwatch_log_group.flow_log.arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        # DescribeLogGroups ne supporte pas de resource restriction
        Resource = "*" #checkov:skip=CKV_AWS_355:DescribeLogGroups requiert Resource:*
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-log"
  })
}

################################################################################
# Subnet public, IGW, Route Table
################################################################################

# CKV_AWS_130 — map_public_ip_on_launch=true intentionnel : subnet PUBLIC
# Une architecture avec subnet privé + NAT Gateway est prévue en v2.
#checkov:skip=CKV_AWS_130:Subnet public par conception — NAT Gateway hors scope v1
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-subnet-public"
    Tier = "public"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rt-public"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
