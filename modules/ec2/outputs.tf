output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "IP publique de l'instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "DNS public de l'instance"
  value       = aws_instance.web.public_dns
}

output "instance_private_ip" {
  description = "IP privée de l'instance"
  value       = aws_instance.web.private_ip
}

output "web_url" {
  description = "URL HTTP du serveur web"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "Commande SSH pour se connecter à l'instance"
  value       = "ssh -i ~/.ssh/terraform_vm_key ubuntu@${aws_instance.web.public_ip}"
}

output "ami_id" {
  description = "ID de l'AMI utilisée"
  value       = data.aws_ami.ubuntu.id
}

output "cpu_alarm_arn" {
  description = "ARN de l'alarme CPU CloudWatch"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "iam_role_arn" {
  description = "ARN du IAM Role attaché à l'instance"
  value       = aws_iam_role.ec2.arn
}

output "iam_instance_profile_name" {
  description = "Nom de l'instance profile IAM"
  value       = aws_iam_instance_profile.ec2.name
}
