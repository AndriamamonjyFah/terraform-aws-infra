output "web_sg_id" {
  description = "ID du Security Group web"
  value       = aws_security_group.web.id
}

output "web_sg_name" {
  description = "Nom du Security Group web"
  value       = aws_security_group.web.name
}

output "web_sg_arn" {
  description = "ARN du Security Group web"
  value       = aws_security_group.web.arn
}
