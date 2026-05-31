# ADR 001 — Remote State S3 et DynamoDB

**Date :** 2026-05-18


---

## Contexte

Terraform génère un fichier `terraform.tfstate` qui représente l'état
réel de l'infrastructure déployée. Sans gestion centralisée, ce fichier
reste en local et pose plusieurs problèmes :

- Perte du state si la machine locale est compromise ou effacée
- Impossibilité de travailler en équipe (conflits de state)
- Absence de versioning et de rollback
- Risque de corruption si deux `terraform apply` tournent simultanément

## Décision

Utiliser **AWS S3** comme backend remote pour stocker le state, combiné
à une table **AWS DynamoDB** pour le verrouillage (state locking).

## Justification


S3 + DynamoDB est retenu car il s'intègre nativement dans l'écosystème
AWS du projet, reste dans le Free Tier, et donne un contrle total sur
les données d'état.

## Conséquences

- Le bucket S3 doit être créé avant le premier `terraform init`
- Le chiffrement S3 (`encrypt = true`) est activé
- Le versioning S3 permet de restaurer un state précédent en cas d'erreur
- Le script `bootstrap_backend.sh` automatise la création de ces ressources

## Alternatives rejetée

- **Terraform Cloud** : dépendance à un service tiers
- **State local** : inacceptable pour tout projet collaboratif
