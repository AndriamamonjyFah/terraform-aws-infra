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

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", var.instance_type))
    error_message = "instance_type doit être un type EC2 valide (ex: t2.micro, t3.small)."
  }
}

variable "subnet_id" {
  description = "ID du subnet dans lequel lancer l'instance"
  type        = string
}

variable "security_group_id" {
  description = "ID du Security Group à associer à l'instance"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin absolu vers la clé publique SSH locale"
  type        = string
}

variable "root_volume_size" {
  description = "Taille du volume root en Go"
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "root_volume_size doit être entre 8 et 100 Go."
  }
}

variable "cpu_alarm_threshold" {
  description = "Seuil CPU (%) déclenchant l'alarme CloudWatch"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "cpu_alarm_threshold doit être entre 1 et 100."
  }
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}

variable "ebs_optimized" {
  description = "Activer l'optimisation EBS (non disponible sur t2.micro — mettre false en dev)"
  type        = bool
  default     = false
}
