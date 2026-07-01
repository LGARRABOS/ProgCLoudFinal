variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "assume_role_arn" {
  description = "ARN du rôle IAM à assumer (laisser vide pour utiliser les clés directement)"
  type        = string
  default     = ""
}

variable "project_prefix" {
  description = "Préfixe unique pour nommer les ressources"
  type        = string
}

provider "aws" {
  region = var.aws_region

  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []
    content {
      role_arn = var.assume_role_arn
    }
  }

  default_tags {
    tags = {
      Project = "ynov-iac-2025"
    }
  }
}
