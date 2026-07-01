provider "aws" {
  region = var.aws_region

  # Les clés Access/Secret fournies par l'intervenant sont lues depuis
  # l'environnement (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY), puis on
  # assume le rôle IAM restreint pour effectuer les opérations.
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = "ynov-iac-2025"
  }

  # Tag obligatoire appliqué AUTOMATIQUEMENT à toutes les ressources taguables.
  # Une ressource non taguée est refusée par la policy IAM.
  default_tags {
    tags = {
      Project = var.project_tag
    }
  }
}
