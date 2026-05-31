# ADR 002 — Structure multi-environnements par répertoires

**Date :** 2026-05-23  


## Contexte

Le projet cible trois environnements : dev, staging, prod.
Il existe deux approches principales pour les gérer avec Terraform :
1. **Workspaces** : un seul code, plusieurs états via `terraform workspace`
2. **Répertoires séparés** : un dossier `environments/<env>/` par contexte

## Décision

Utiliser des **répertoires séparés** par environnement.

## Justification



L'isolation totale des states par répertoire est critique en production :
un `terraform destroy` accidentel dans le mauvais workspace avec les
workspaces peut détruire la prod. Les répertoires imposent une navigation
explicite (`cd environments/prod`) avant tout apply.

## Conséquences

- Légère duplication des fichiers `backend.tf` et `variables.tf`
- Compensée par l'utilisation de modules communs (pas de duplication du code infra)
- Chaque environnement a son propre state S3 (`dev/`, `staging/`, `prod/`)
