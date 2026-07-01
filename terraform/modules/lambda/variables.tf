variable "function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "package_path" {
  description = "Chemin du zip de déploiement (généré par build.sh)"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN du bucket source (lecture)"
  type        = string
}

variable "destination_bucket_arn" {
  description = "ARN du bucket destination (écriture)"
  type        = string
}

variable "destination_bucket_name" {
  description = "Nom du bucket destination (variable d'env de la Lambda)"
  type        = string
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
}

variable "runtime" {
  description = "Runtime de la Lambda"
  type        = string
  default     = "python3.11"
}
