# Preuves d'exécution — AWS CLI

Ce document liste les commandes à exécuter pour démontrer le bon fonctionnement de l'infrastructure lors de la soutenance.

## 1. Assume Role

```powershell
aws sts assume-role `
  --role-arn arn:aws:iam::738563260931:role/role_etudiants `
  --role-session-name ynov-session
```

**Résultat attendu :** JSON contenant `Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`.

---

## 2. Lister les buckets S3

```powershell
aws s3 ls
```

**Résultat attendu :**
```
lgarrabos-source-images
lgarrabos-dest-pdfs
```

---

## 3. Vérifier le contenu du bucket source

```powershell
aws s3 ls s3://lgarrabos-source-images/
```

---

## 4. Upload d'une image de test

```powershell
aws s3 cp test.jpg s3://lgarrabos-source-images/test.jpg
```

---

## 5. Vérifier la conversion PDF dans le bucket destination

Attendre quelques secondes puis :

```powershell
aws s3 ls s3://lgarrabos-dest-pdfs/
```

**Résultat attendu :** un fichier `test_YYYYMMDD_HHMMSS.pdf`

---

## 6. Télécharger et vérifier le PDF

```powershell
aws s3 cp s3://lgarrabos-dest-pdfs/test_YYYYMMDD_HHMMSS.pdf ./output.pdf
```

---

## 7. Logs CloudWatch de la Lambda

```powershell
aws logs tail /aws/lambda/lgarrabos-image-to-pdf --follow
```

**Résultat attendu :** logs de conversion `Conversion ... -> ...` et `PDF déposé`.

---

## 8. Vérifier les tags des ressources

```powershell
aws s3api get-bucket-tagging --bucket lgarrabos-source-images
aws lambda list-tags --resource arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:lgarrabos-image-to-pdf
```

**Résultat attendu :** tag `Project = ynov-iac-2025` sur toutes les ressources.

---

## 9. Mise à jour Ansible

```powershell
cd ansible
ansible-playbook playbooks/update_lambda.yml
```

**Résultat attendu :** `Lambda lgarrabos-image-to-pdf mise à jour`.

---

## 10. Pipeline CI/CD

Vérifier sur GitHub Actions que le workflow `Terraform CI/CD` passe avec succès :
- Terraform fmt / validate / plan
- Checkov
- Infracost
- ansible-lint
