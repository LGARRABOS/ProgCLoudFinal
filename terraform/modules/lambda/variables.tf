variable "function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN du bucket S3 source"
  type        = string
}

variable "dest_bucket_name" {
  description = "Nom du bucket S3 destination"
  type        = string
}

variable "dest_bucket_arn" {
  description = "ARN du bucket S3 destination"
  type        = string
}

variable "lambda_source_dir" {
  description = "Chemin vers le dossier source Lambda"
  type        = string
}

variable "handler" {
  description = "Handler Lambda"
  type        = string
  default     = "handler.handler"
}

variable "runtime" {
  description = "Runtime Lambda"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Timeout Lambda en secondes"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Mémoire Lambda en Mo"
  type        = number
  default     = 256
}

variable "tags" {
  description = "Tags additionnels"
  type        = map(string)
  default     = {}
}
