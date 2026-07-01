variable "aws_region" {
  description = "Région AWS de déploiement"
  type        = string
  default     = "eu-west-3"
}

variable "assume_role_arn" {
  description = "ARN du rôle IAM restreint à assumer (fourni par l'intervenant)"
  type        = string
}

variable "project_tag" {
  description = "Valeur du tag Project obligatoire"
  type        = string
  default     = "ynov-iac-2025"
}

variable "source_bucket_name" {
  description = "Nom (globalement unique) du bucket source des images"
  type        = string
}

variable "destination_bucket_name" {
  description = "Nom (globalement unique) du bucket de destination des PDF"
  type        = string
}

variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
  default     = "ynov-image-to-pdf"
}

variable "lambda_package_path" {
  description = "Chemin du zip Lambda généré par build.sh"
  type        = string
  default     = "../build/lambda_package.zip"
}
