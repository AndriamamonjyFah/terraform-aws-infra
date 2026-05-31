variable "project_name" {
  description = "Nom du projet — utilisé comme préfixe pour toutes les ressources"
  type        = string

  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "project_name doit contenir entre 3 et 20 caractères."
  }
}

variable "environment" {
  description = "Nom de l'environnement cible"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit être : dev, staging ou prod."
  }
}

variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC (ex: 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr doit être un CIDR valide (ex: 10.0.0.0/16)."
  }
}

variable "subnet_public_cidr" {
  description = "CIDR block du subnet public (doit être inclus dans vpc_cidr)"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_public_cidr, 0))
    error_message = "subnet_public_cidr doit être un CIDR valide (ex: 10.0.1.0/24)."
  }
}

variable "common_tags" {
  description = "Tags communs appliqués à toutes les ressources du module"
  type        = map(string)
  default     = {}
}
