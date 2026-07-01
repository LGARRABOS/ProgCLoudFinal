# ProgCLoudFinal — Projet Ynov IaC 2025

Infrastructure AWS déployée avec **Terraform** (modules réutilisables), handler **Lambda Python 3.11** (conversion image → PDF), mise à jour via **Ansible**, pipeline **GitHub Actions**.

## Architecture

- **Bucket S3 source** : réception des images (`.jpg`, `.jpeg`, `.png`)
- **Lambda** : déclenchée par événement S3, renomme et convertit en PDF via `img2pdf`
- **Bucket S3 destination** : stockage des PDFs générés

Tag obligatoire sur toutes les ressources : `Project = "ynov-iac-2025"`

## Prérequis

| Outil | Version |
|-------|---------|
| Terraform | ≥ 1.6 |
| AWS CLI | ≥ 2.x |
| Python | 3.11 |
| pip | récent |
| Ansible | ≥ 2.15 |
| PowerShell | 5+ (build Lambda sur Windows) |

## Configuration

1. Copier le fichier de variables :
   ```powershell
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Configurer les credentials AWS (ne jamais les committer) :
   ```powershell
   $env:AWS_ACCESS_KEY_ID="VOTRE_ACCESS_KEY"
   $env:AWS_SECRET_ACCESS_KEY="VOTRE_SECRET_KEY"
   $env:AWS_DEFAULT_REGION="eu-west-3"
   ```

3. Vérifier l'Assume Role :
   ```powershell
   aws sts assume-role `
     --role-arn arn:aws:iam::738563260931:role/role_etudiants `
     --role-session-name ynov-session
   ```

## Dépannage AWS

### Assume Role

Le compte AWS étudiant (`ynov-student`) **ne peut pas** créer de ressources directement. Vous devez assumer le rôle IAM fourni par l'intervenant :

```powershell
aws sts assume-role `
  --role-arn arn:aws:iam::738563260931:role/role_etudiants `
  --role-session-name ynov-session
```

Si cette commande retourne `AccessDenied`, demandez l'**ARN exact du rôle** à votre intervenant et mettez-le à jour dans `terraform/terraform.tfvars`.

### Tag obligatoire

Toutes les ressources portent automatiquement `Project = "ynov-iac-2025"` via `default_tags` du provider Terraform.

## Déploiement Terraform

```powershell
cd terraform
terraform init
terraform plan
terraform apply
```

## Test end-to-end

```powershell
# Récupérer le nom du bucket source
$SOURCE = terraform output -raw source_bucket_name

# Uploader une image de test
aws s3 cp test.jpg s3://$SOURCE/test.jpg

# Vérifier le PDF dans le bucket destination
$DEST = terraform output -raw dest_bucket_name
aws s3 ls s3://$DEST/

# Consulter les logs Lambda
$LAMBDA = terraform output -raw lambda_function_name
aws logs tail "/aws/lambda/$LAMBDA" --follow
```

## Mise à jour Lambda via Ansible

```powershell
cd ansible
$env:AWS_ACCESS_KEY_ID = "VOTRE_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY = "VOTRE_SECRET_KEY"
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/update_lambda.yml
```

## Pipeline CI/CD

Le workflow [`.github/workflows/terraform.yaml`](.github/workflows/terraform.yaml) exécute :

- `terraform fmt -check`
- `terraform validate`
- `terraform plan`
- **Checkov** (scan sécurité)
- **Infracost** (estimation coûts)
- **ansible-lint**

### GitHub Secrets requis

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Clé d'accès AWS |
| `AWS_SECRET_ACCESS_KEY` | Clé secrète AWS |
| `AWS_ROLE_ARN` | `arn:aws:iam::738563260931:role/role_etudiants` |
| `INFRACOST_API_KEY` | Clé API Infracost (gratuite) |

## Structure du projet

```
├── .github/workflows/terraform.yaml
├── ansible/
│   ├── playbooks/update_lambda.yml
│   ├── inventory/hosts.yml
│   └── group_vars/all.yml
├── lambda/
│   ├── handler.py
│   └── requirements.txt
├── terraform/
│   ├── main.tf
│   ├── modules/s3/
│   ├── modules/lambda/
│   └── scripts/build_lambda.ps1
└── docs/preuves-cli.md
```

## Auteur

Projet réalisé dans le cadre du module **Programmation pour le Cloud** — Ynov Bordeaux 2026.
Luc GARRABOS
Fabien GARCIA
Maxence GILLES
