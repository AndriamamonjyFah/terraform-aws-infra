output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block du VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnet_public_id" {
  description = "ID du subnet public"
  value       = aws_subnet.public.id
}

output "subnet_public_cidr" {
  description = "CIDR block du subnet public"
  value       = aws_subnet.public.cidr_block
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "route_table_public_id" {
  description = "ID de la Route Table publique"
  value       = aws_route_table.public.id
}

output "flow_log_id" {
  description = "ID du VPC Flow Log"
  value       = aws_flow_log.vpc.id
}

output "default_security_group_id" {
  description = "ID du default Security Group (restreint)"
  value       = aws_default_security_group.default.id
}

output "kms_key_arn" {
  description = "ARN de la clé KMS pour les flow logs"
  value       = aws_kms_key.flow_log.arn
}
