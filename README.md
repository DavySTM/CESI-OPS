# Projet Cloud & DevOps - Application Deployment

Ce projet implémente une infrastructure cloud complète sur Google Cloud Platform (GCP) en utilisant les meilleures pratiques DevOps. Il est structuré en deux projets distincts : un projet Ops pour la gestion de l'infrastructure et un projet App pour l'hébergement de l'application.

## Architecture

Le projet utilise les services GCP suivants :
- Artifact Registry pour le stockage des artefacts
- Cloud Build pour la CI/CD
- Compute Engine pour l'hébergement
- Cloud Monitoring pour la surveillance
- Cloud DNS pour la gestion des domaines

## Structure du Projet

```
.
├── ops/
│   ├── cloudbuild/
│   │   ├── app-build.yaml        # Pipeline de build de l'application
│   │   ├── packer-build.yaml     # Pipeline de création d'image
│   │   └── terraform-bucket.yaml # Pipeline de création du bucket d'état
│   ├── packer/
│   │   ├── Dockerfile           # Configuration Docker pour Packer+Ansible
│   │   └── build.pkr.hcl        # Configuration Packer
│   ├── ansible/
│   │   ├── playbook.yml         # Playbook principal
│   │   ├── app.service.j2       # Template systemd
│   │   └── roles/
│   │       └── ops_agent/       # Rôle pour l'installation de l'agent GCP
│   │           └── tasks/
│   │               └── main.yml
│   └── terraform/
│       └── gcs/                 # Configuration Terraform pour le bucket d'état
│           ├── main.tf
│           └── variables.tf
└── prod/
    ├── app.tar.gz              # Application packagée
    └── terraform/              # Infrastructure de l'application
        ├── main.tf             # Configuration principale
        ├── variables.tf        # Variables Terraform
        ├── network.tf          # Configuration réseau
        ├── compute.tf          # Configuration des instances
        ├── dns.tf              # Configuration DNS
        ├── monitoring.tf       # Configuration du monitoring
        └── storage.tf          # Configuration du stockage
```

## Fonctionnalités

### Projet Ops

Le projet Ops gère trois pipelines Cloud Build distinctes :

1. **Pipeline Application**
   - Upload de l'application dans Artifact Registry
   - Scan de sécurité des secrets
   - Scan de vulnérabilités

2. **Pipeline Image**
   - Construction de l'image système avec Packer
   - Configuration via Ansible
   - Installation de l'application et de l'OpsAgent

3. **Pipeline État Terraform**
   - Création du bucket GCS pour les états Terraform
   - Configuration du versionning pour la sécurité

### Projet App

Le projet App déploie l'infrastructure suivante :

- VPC dédié
- Sous-réseaux pour l'application et le load balancer
- Bucket GCS public pour les fichiers statiques
- Managed Instance Group (MIG) avec auto-scaling
- Load Balancer régional
- Zone DNS dédiée
- Dashboard de monitoring avec métriques :
  - Trafic du load balancer
  - Utilisation CPU/RAM du MIG

## Déploiement

### Prérequis
- GCP CLI installé et configuré
- Deux projets GCP créés (Ops et App)
- APIs nécessaires activées

### Étapes de déploiement

1. Upload de l'application :
```bash
gcloud builds submit . --config=ops/cloudbuild/app-build.yaml
```

2. Création du bucket Terraform :
```bash
gcloud builds submit --config ops/cloudbuild/terraform-bucket.yaml
```

3. Création de l'image :
```bash
gcloud builds submit . --config=ops/cloudbuild/packer-build.yaml
```

4. Déploiement de l'infrastructure :
```bash
cd prod/terraform
terraform init
terraform plan
terraform apply
```

## Monitoring

Le projet inclut un dashboard Cloud Monitoring qui affiche :
- Les métriques de trafic du load balancer
- L'utilisation CPU et mémoire des instances
- Les logs d'application via l'OpsAgent

## Sécurité

- Accès uniforme aux buckets
- Versionning des états Terraform
- Scan de sécurité automatisé des artefacts
- Réseau segmenté avec sous-réseaux dédiés

## Maintenance

Pour mettre à jour l'application :
1. Packager la nouvelle version
2. Lancer la pipeline de build
3. Mettre à jour l'image via Packer
4. Terraform appliquera les changements automatiquement

## Support

Pour toute question ou problème, consultez :
- La documentation GCP
- Les logs Cloud Build
- Les métriques de monitoring