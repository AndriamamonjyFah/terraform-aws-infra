################################################################################
# Module : EC2
# Description : Crée une instance EC2 Ubuntu avec provisioning automatique
#               Nginx via user_data. Inclut alarmes CloudWatch, IAM role
#               et monitoring détaillé.
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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file(var.ssh_public_key_path)

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-key"
  })
}

################################################################################
# Checkov CKV2_AWS_41 — IAM Role attaché à l'instance EC2
################################################################################

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
  })
}

################################################################################
# Instance EC2
################################################################################

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name # CKV2_AWS_41

  # Checkov CKV_AWS_126 — Monitoring détaillé activé
  monitoring = true

  # Checkov CKV_AWS_135 — EBS optimized (true pour les types qui le supportent)
  ebs_optimized = var.ebs_optimized

  user_data = base64encode(templatefile("${path.module}/../../scripts/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
    })
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 — protection SSRF
    http_put_response_hop_limit = 1
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-server"
    Role = "web"
  })
}

################################################################################
# CloudWatch — Alarme CPU haute
################################################################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "CPU > ${var.cpu_alarm_threshold}% pendant 4 min sur ${var.environment}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cpu-alarm"
  })
}

################################################################################
# CloudWatch — Alarme statut d'instance
################################################################################

resource "aws_cloudwatch_metric_alarm" "instance_status" {
  alarm_name          = "${var.project_name}-${var.environment}-instance-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Échec status check sur ${var.environment}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-status-alarm"
  })
}
