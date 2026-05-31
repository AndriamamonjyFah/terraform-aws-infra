variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "my-infra"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "owner" {
  description = "Propriétaire / équipe responsable"
  type        = string
  default     = "team-infra"
}

variable "github_username" {
  description = "Nom d'utilisateur GitHub"
  type        = string
  default     = "your-username"
}

variable "vpc_cidr" {
  description = "CIDR du VPC staging"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_public_cidr" {
  description = "CIDR du subnet public staging"
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "Type EC2 staging"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Taille volume root (Go)"
  type        = number
  default     = 30
}

variable "cpu_alarm_threshold" {
  description = "Seuil CPU alarme (%)"
  type        = number
  default     = 75
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorisé pour SSH — restreindre en staging"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique"
  type        = string
}

variable "ebs_optimized" {
  description = "Activer l'optimisation EBS (false pour t2.micro)"
  type        = bool
  default     = false
}
