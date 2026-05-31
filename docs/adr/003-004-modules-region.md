# ADR 003 — Modules Terraform locaux

**Date :** 2026-05-29 


## Contexte

Le code Terraform peut être organisé en fichiers plats (tout dans un
dossier) ou en modules réutilisables. Pour un projet multi-environnements,
les modules deviennent indispensables pour éviter la duplication.

## Décision

Utiliser des **modules Terraform locaux** dans `modules/` pour encapsuler
chaque couche infrastructure : vpc, security, ec2.

## Justification

- **DRY (Don't Repeat Yourself)** : les 3 environnements appellent les mêmes
  modules avec des variables différentes ,le code réseau n'est écrit qu'une fois
- **Testabilité** : chaque module peut être validé et linté indépendamment
- **Portfolio** : les modules locaux démontrent une maitrise de l'abstraction
  Terraform, attendue en entretien Cloud/DevOps
- **Évolutivité** : les modules peuvent être publiés dans un registry Terraform
  

## Conséquences

- Chaque module expose ses outputs pour être consommé par les environnements
- Les références croisées (`module.vpc.vpc_id`) documentent les dépendances
- Les variables typées avec blocs `validation {}` garantissent l'intégrité des inputs

---

# ADR 004 — Région AWS eu-west-3 (Paris)

**Date :** 2024-05-31  


## Contexte

AWS propose des dizaines de régions. Le choix impacte la latence, la conformité réglementaire et les coûts

## Décision

Utiliser la région **eu-west-3 (Paris)** comme région principale.



## Conséquences

- Tous les backends S3 pointent vers `eu-west-3`
- L'AMI Ubuntu est filtrée dynamiquement 
- Changer de région ne nécessite que de modifier la variable `aws_region`
