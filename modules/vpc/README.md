# Module — VPC

Ce module crée un réseau AWS complet comprenant un VPC, un subnet public,
une Internet Gateway et une Route Table associée.

## Ressources créées

| Ressource | Description |
|---|---|
| `aws_vpc` | VPC principal avec DNS activé |
| `aws_subnet` | Subnet public avec attribution d'IP automatique |
| `aws_internet_gateway` | Passerelle Internet |
| `aws_route_table` | Table de routage publique (0.0.0.0/0 → IGW) |
| `aws_route_table_association` | Association subnet ↔ route table |

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name       = "my-infra"
  environment        = "dev"
  aws_region         = "eu-west-3"
  vpc_cidr           = "10.0.0.0/16"
  subnet_public_cidr = "10.0.1.0/24"

  common_tags = {
    Project     = "my-infra"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "team-infra"
  }
}
```

## Inputs

| Nom | Description | Type | Défaut | Requis |
|---|---|---|---|---|
| `project_name` | Préfixe des ressources (3-20 chars) | `string` | — | oui |
| `environment` | dev / staging / prod | `string` | — | oui |
| `aws_region` | Région AWS | `string` | `eu-west-3` | non |
| `vpc_cidr` | CIDR du VPC | `string` | — | oui |
| `subnet_public_cidr` | CIDR du subnet public | `string` | — | oui |
| `common_tags` | Tags communs | `map(string)` | `{}` | non |

## Outputs

| Nom | Description |
|---|---|
| `vpc_id` | ID du VPC |
| `vpc_cidr` | CIDR du VPC |
| `subnet_public_id` | ID du subnet public |
| `subnet_public_cidr` | CIDR du subnet public |
| `internet_gateway_id` | ID de l'IGW |
| `route_table_public_id` | ID de la Route Table |

## Architecture

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
Route Table (0.0.0.0/0 → IGW)
    │
    ▼
Subnet Public (map_public_ip = true)
    │
    ▼
VPC (dns_hostnames + dns_support activés)
```

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
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_alias.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Région AWS cible | `string` | `"eu-west-3"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags communs appliqués à toutes les ressources du module | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement cible | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet — utilisé comme préfixe pour toutes les ressources | `string` | n/a | yes |
| <a name="input_subnet_public_cidr"></a> [subnet\_public\_cidr](#input\_subnet\_public\_cidr) | CIDR block du subnet public (doit être inclus dans vpc\_cidr) | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block du VPC (ex: 10.0.0.0/16) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | ID du default Security Group (restreint) |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | ID du VPC Flow Log |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID de l'Internet Gateway |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN de la clé KMS pour les flow logs |
| <a name="output_route_table_public_id"></a> [route\_table\_public\_id](#output\_route\_table\_public\_id) | ID de la Route Table publique |
| <a name="output_subnet_public_cidr"></a> [subnet\_public\_cidr](#output\_subnet\_public\_cidr) | CIDR block du subnet public |
| <a name="output_subnet_public_id"></a> [subnet\_public\_id](#output\_subnet\_public\_id) | ID du subnet public |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block du VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID du VPC créé |
<!-- END_TF_DOCS -->