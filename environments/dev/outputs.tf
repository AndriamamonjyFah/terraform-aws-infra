output "vpc_id" {
  description = "ID du VPC dev"
  value       = module.vpc.vpc_id
}

output "web_server_public_ip" {
  description = "IP publique du serveur web dev"
  value       = module.ec2.instance_public_ip
}

output "web_url" {
  description = "URL du serveur web dev"
  value       = module.ec2.web_url
}

output "ssh_command" {
  description = "Commande SSH pour se connecter"
  value       = module.ec2.ssh_command
  sensitive   = false
}

output "security_group_id" {
  description = "ID du Security Group web"
  value       = module.security.web_sg_id
}
