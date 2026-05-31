# Architecture — terraform-aws-infra

## Vue d'ensemble

Ce projet déploie une infrastructure web AWS reproductible, modulaire
et multi-environnements, entièrement gérée en Infrastructure as Code (IaC)
avec Terraform.

## Diagramme d'architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AWS Region (eu-west-3)                      │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.x.0.0/16)                         │   │
│  │                                                              │   │
│  │  ┌─────────────────────────────────────────────────────┐    │   │
│  │  │              Subnet Public (10.x.1.0/24)            │    │   │
│  │  │                                                     │    │   │
│  │  │   ┌──────────────────────────────────────────┐      │    │   │
│  │  │   │         Security Group (web-sg)          │      │    │   │
│  │  │   │  Inbound : 80/tcp, 443/tcp, 22/tcp       │      │    │   │
│  │  │   │  Outbound : all                          │      │    │   │
│  │  │   │                                          │      │    │   │
│  │  │   │   ┌──────────────────────────────────┐   │      │    │   │
│  │  │   │   │     EC2 Instance (t2.micro)       │   │      │    │   │
│  │  │   │   │     Ubuntu 22.04 LTS             │   │      │    │   │
│  │  │   │   │     Nginx (via user_data)         │   │      │    │   │
│  │  │   │   │     Volume root gp3 chiffré       │   │      │    │   │
│  │  │   │   │     IMDSv2 activé                 │   │      │    │   │
│  │  │   │   └──────────────────────────────────┘   │      │    │   │
│  │  │   └──────────────────────────────────────────┘      │    │   │
│  │  └─────────────────────────────────────────────────────┘    │   │
│  │                           │                                  │   │
│  │                    Route Table                               │   │
│  │                    0.0.0.0/0 → IGW                          │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                    Internet Gateway                                 │
└─────────────────────────────────────────────────────────────────────┘
                               │
                           Internet
                               │
                           Utilisateurs (HTTP/HTTPS)
                           Admin     (SSH)
```

## Séparation des environnements

| Env | CIDR VPC | Instance | SSH | Usage |
|---|---|---|---|---|
| `dev` | 10.0.0.0/16 | t2.micro | 0.0.0.0/0 | Développement local |
| `staging` | 10.1.0.0/16 | t3.small | IP restreinte | Pré-production |
| `prod` | 10.2.0.0/16 | t3.medium | IP admin/32 | Production |

Les CIDR différents permettent un futur VPC Peering entre environnements
sans conflit d'adressage.

## Structure des modules

```
modules/
├── vpc/        Réseau : VPC, Subnet, IGW, Route Table
├── security/   Firewall : Security Groups et règles
└── ec2/        Compute : Instance, KeyPair, CloudWatch alarms
```

Chaque environnement appelle ces modules avec ses propres variables —
aucun code n'est dupliqué.

## Remote State

Le state Terraform est centralisé dans S3 avec verrouillage DynamoDB :

```
S3 Bucket
├── dev/terraform.tfstate
├── staging/terraform.tfstate
└── prod/terraform.tfstate

DynamoDB Table : terraform-state-lock
```

## Flux de déploiement

```
Developer
    │
    ├── git push → GitHub
    │                │
    │                ▼
    │         GitHub Actions CI
    │         ├── terraform fmt --check
    │         ├── terraform validate (×3 envs)
    │         ├── tflint
    │         └── checkov (security scan)
    │
    └── make plan ENV=dev
              │
              ▼
         Review du plan
              │
              ▼
         make apply ENV=dev
              │
              ▼
         AWS Infrastructure
```

## Décisions d'architecture

Voir le dossier `docs/adr/` pour le détail des décisions.

| ADR | Décision |
|---|---|
| [001](adr/001-remote-state-s3.md) | Remote state S3 + DynamoDB |
| [002](adr/002-multi-env-directories.md) | Structure multi-env par répertoires |
| [003](adr/003-modules-terraform.md) | Modules Terraform locaux |
| [004](adr/004-region-eu-west-3.md) | Région eu-west-3 (Paris) |
