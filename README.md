# terraform-aws-infra

> Infrastructure AWS complète, modulaire et multi-environnements,
> entièrement gérée en Infrastructure as Code avec Terraform.

![CI](https://github.com/AndriamamonjyFah/terraform-aws-infra/actions/workflows/terraform-ci.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-≥1.6-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-eu--west--3-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Présentation

Ce projet démontre la conception et la gestion d'une infrastructure cloud AWS
professionnelle en suivant les bonnes pratiques IaC :

- **Modules Terraform réutilisables** — VPC, Security Groups, EC2
- **Multi-environnements** — dev, staging, prod avec configurations isolées
- **Remote state** — S3 + DynamoDB pour la collaboration et la sécurité
- **CI/CD** — GitHub Actions : fmt, validate, tflint, checkov
- **Sécurité intégrée** — IMDSv2, chiffrement EBS, Security Groups stricts
- **Documentation** — ADR, diagrammes d'architecture, estimation de coûts



---

## Architecture

```
Internet
    │
Internet Gateway
    │
Route Table (0.0.0.0/0 → IGW)
    │
Subnet Public
    │
Security Group (80, 443, 22)
    │
EC2 Ubuntu 22.04 + Nginx
    │
EBS gp3 (chiffré)
```

Voir [`docs/architecture.md`](docs/architecture.md) pour le diagramme complet.

---

## Structure du projet

```
terraform-aws-infra/
├── .github/workflows/       CI GitHub Actions
├── modules/                 Modules Terraform réutilisables
│   ├── vpc/                 Réseau (VPC, Subnet, IGW, Route Table)
│   ├── ec2/                 Compute (Instance, KeyPair, CloudWatch)
│   └── security/            Firewall (Security Groups)
├── environments/            Configurations par environnement
│   ├── dev/                 t2.micro — Free Tier
│   ├── staging/             t3.small — pré-production
│   └── prod/                t3.medium — production
├── scripts/
│   ├── user_data.sh         Provisioning automatique Nginx
│   └── bootstrap_backend.sh Création S3 + DynamoDB
├── docs/
│   ├── architecture.md      Diagramme et description
│   ├── cost-estimation.md   Estimation des coûts AWS
│   └── adr/                 Architecture Decision Records
├── .tflint.hcl              Configuration TFLint
├── .pre-commit-config.yaml  Hooks git
├── Makefile                 Commandes standardisées
└── CHANGELOG.md             Historique des versions
```

---

## Prérequis

| Outil | Version | Installation |
|---|---|---|
| Terraform | ≥ 1.6 | [terraform.io](https://terraform.io) |
| AWS CLI | v2 | [docs.aws.amazon.com](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Git | ≥ 2.x | `apt install git` |
| Make | — | `apt install make` |
| TFLint | latest | `make install-tools` |
| Checkov | latest | `make install-tools` |

---

## Démarrage rapide

### 1. Cloner le repo

```bash
git clone git@github.com:AndriamamonjyFah/terraform-aws-infra.git
cd terraform-aws-infra
```

### 2. Installer les outils

```bash
make install-tools
```

### 3. Configurer AWS CLI

```bash
aws configure --profile terraform-project

```

### 4. Bootstrap du backend (une seule fois)

```bash
make bootstrap
# Saisir un nom de bucket unique
```

### 5. Mettre à jour les backends

Remplacer `TON_BUCKET_NAME` dans les 3 fichiers :
- `environments/dev/backend.tf`
- `environments/staging/backend.tf`
- `environments/prod/backend.tf`

### 6. Configurer les variables

```bash
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
# Editer terraform.tfvars avec vos info
```

### 7. Valider le code (sans AWS)

```bash
make all-validate   # Valide les 3 environnements
make lint           # TFLint
make checkov        # Scan sécurité
```

### 8. Déployer (nécessite un compte AWS)

```bash
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

---

## Commandes Make

```bash
make help              # Afficher toutes les commandes
make all-validate      # Valider fmt + validate 
make lint              # TFLint sur modules et environnements
make checkov           # Scan sécurité Checkov
make fmt               # Formater le code
make docs              # Générer la documentation
make plan ENV=dev      # Plan de déploiement dev
make apply ENV=dev     # Déployer dev
make destroy ENV=dev   # Détruire dev
make output ENV=dev    # Afficher les outputs
make clean             # Nettoyer les fichiers temporaires
```

---

## Environnements

| Env | VPC CIDR | Instance | SSH | State S3 |
|---|---|---|---|---|
| `dev` | 10.0.0.0/16 | t2.micro | 0.0.0.0/0 | `dev/terraform.tfstate` |
| `staging` | 10.1.0.0/16 | t3.small | IP restreinte | `staging/terraform.tfstate` |
| `prod` | 10.2.0.0/16 | t3.medium | IP/32 obligatoire | `prod/terraform.tfstate` |

---

## Sécurité

- **IMDSv2** imposé sur toutes les instances (protection SSRF)
- **Volume EBS chiffré** par défaut (gp3 + chiffrement AWS managed key)
- **SSH restreint** à l'IP admin en staging et prod
- **Checkov** intégré en CI — scanne les misconfigurations Terraform
- **Secrets** exclus du repo via `.gitignore` (tfstate, tfvars, clés SSH)
- **DynamoDB lock** — empêche les apply concurrents

---

## Documentation

- [`docs/architecture.md`](docs/architecture.md) — Diagramme et flux
- [`docs/adr/`](docs/adr/) — Décisions d'architecture (ADR)
- Chaque module a son propre `README.md` avec inputs/outputs

---


