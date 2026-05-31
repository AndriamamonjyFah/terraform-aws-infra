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
| [aws_security_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.all_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags communs | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement cible (dev / staging / prod) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet | `string` | n/a | yes |
| <a name="input_ssh_allowed_cidr"></a> [ssh\_allowed\_cidr](#input\_ssh\_allowed\_cidr) | CIDR autorisé pour le SSH (restreindre à ton IP en prod : X.X.X.X/32) | `string` | `"0.0.0.0/0"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID du VPC dans lequel créer le Security Group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_sg_arn"></a> [web\_sg\_arn](#output\_web\_sg\_arn) | ARN du Security Group web |
| <a name="output_web_sg_id"></a> [web\_sg\_id](#output\_web\_sg\_id) | ID du Security Group web |
| <a name="output_web_sg_name"></a> [web\_sg\_name](#output\_web\_sg\_name) | Nom du Security Group web |
<!-- END_TF_DOCS -->