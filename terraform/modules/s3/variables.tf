variable "bucket_name" {
  description = "Nom du bucket S3 (globalement unique)"
  type        = string
}

variable "tags" {
  description = "Tags additionnels pour le bucket"
  type        = map(string)
  default     = {}
}
