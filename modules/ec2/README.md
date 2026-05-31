# Module — EC2

Ce module crée une instance EC2 Ubuntu 22.04 LTS avec :
- Provisioning automatique Nginx via `user_data`
- Volume root chiffré (gp3)
- IMDSv2 obligatoire (protection contre les attaques SSRF)
- Deux alarmes CloudWatch : CPU haute et status check

## Ressources créées

| Ressource | Description |
|---|---|
| `data.aws_ami` | Dernière AMI Ubuntu 22.04 LTS (Canonical) |
| `aws_key_pair` | Paire de clés SSH |
| `aws_instance` | Instance EC2 avec user_data Nginx |
| `aws_cloudwatch_metric_alarm` (×2) | Alarmes CPU et status check |

## Usage

```hcl
module "ec2" {
  source = "../../modules/ec2"

  project_name        = "my-infra"
  environment         = "dev"
  instance_type       = "t2.micro"
  subnet_id           = module.vpc.subnet_public_id
  security_group_id   = module.security.web_sg_id
  ssh_public_key_path = "~/.ssh/terraform_vm_key.pub"
  root_volume_size    = 20
  cpu_alarm_threshold = 80

  common_tags = {
    Project     = "my-infra"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Nom | Description | Type | Défaut | Requis |
|---|---|---|---|---|
| `project_name` | Nom du projet | `string` | — | oui |
| `environment` | dev / staging / prod | `string` | — | oui |
| `instance_type` | Type EC2 | `string` | `t2.micro` | non |
| `subnet_id` | ID subnet | `string` | — | oui |
| `security_group_id` | ID Security Group | `string` | — | oui |
| `ssh_public_key_path` | Chemin clé SSH publique | `string` | — | oui |
| `root_volume_size` | Taille volume root (Go) | `number` | `20` | non |
| `cpu_alarm_threshold` | Seuil CPU alarme (%) | `number` | `80` | non |
| `common_tags` | Tags communs | `map(string)` | `{}` | non |

## Outputs

| Nom | Description |
|---|---|
| `instance_id` | ID EC2 |
| `instance_public_ip` | IP publique |
| `instance_public_dns` | DNS public |
| `instance_private_ip` | IP privée |
| `web_url` | URL HTTP |
| `ssh_command` | Commande SSH complète |
| `ami_id` | ID AMI utilisée |
| `cpu_alarm_arn` | ARN alarme CPU |

## Sécurité

- Volume root chiffré avec clé AWS managée
- IMDSv2 imposé (`http_tokens = "required"`) — protège contre les attaques de type SSRF
- `delete_on_termination = true` sur le volume root

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.instance_status](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags communs | `map(string)` | `{}` | no |
| <a name="input_cpu_alarm_threshold"></a> [cpu\_alarm\_threshold](#input\_cpu\_alarm\_threshold) | Seuil CPU (%) déclenchant l'alarme CloudWatch | `number` | `80` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Activer l'optimisation EBS (non disponible sur t2.micro — mettre false en dev) | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement cible (dev / staging / prod) | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Type d'instance EC2 | `string` | `"t2.micro"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet | `string` | n/a | yes |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Taille du volume root en Go | `number` | `20` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | ID du Security Group à associer à l'instance | `string` | n/a | yes |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Chemin absolu vers la clé publique SSH locale | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID du subnet dans lequel lancer l'instance | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | ID de l'AMI utilisée |
| <a name="output_cpu_alarm_arn"></a> [cpu\_alarm\_arn](#output\_cpu\_alarm\_arn) | ARN de l'alarme CPU CloudWatch |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | Nom de l'instance profile IAM |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN du IAM Role attaché à l'instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID de l'instance EC2 |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | IP privée de l'instance |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | DNS public de l'instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | IP publique de l'instance |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | Commande SSH pour se connecter à l'instance |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | URL HTTP du serveur web |
<!-- END_TF_DOCS -->