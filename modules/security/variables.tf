variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement cible (dev / staging / prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit être : dev, staging ou prod."
  }
}

variable "vpc_id" {
  description = "ID du VPC dans lequel créer le Security Group"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorisé pour le SSH (restreindre à ton IP en prod : X.X.X.X/32)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr doit être un CIDR valide."
  }
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
