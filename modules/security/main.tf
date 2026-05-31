################################################################################
# Module : Security Groups
# Description : Crée les règles firewall pour le web server.
#               Ports : 80 (HTTP public), 443 (HTTPS public), 22 (SSH restreint)
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

resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Firewall web server — ${var.environment}"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP public — Checkov CKV_AWS_260 : port 80 ouvert intentionnellement
# (serveur web public). Supprimé en prod si HTTPS uniquement.
#checkov:skip=CKV_AWS_260:Port 80 ouvert intentionnellement pour le web server public
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP public — web server"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.common_tags, { Name = "allow-http" })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS public"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.common_tags, { Name = "allow-https" })
}

# SSH — Checkov CKV_AWS_24 : CIDR contrôlé par variable ssh_allowed_cidr
# En dev : 0.0.0.0/0 acceptable. En prod : obligatoirement TON_IP/32.
#checkov:skip=CKV_AWS_24:CIDR SSH contrôlé par variable — restreint à l'IP admin en prod
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH admin — restreindre à IP/32 en prod"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_allowed_cidr

  tags = merge(var.common_tags, { Name = "allow-ssh-restricted" })
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.web.id
  description       = "Tout le trafic sortant autorisé"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.common_tags, { Name = "allow-all-egress" })
}
