output "source_bucket" {
  description = "Nom du bucket source"
  value       = module.s3.source_bucket_id
}

output "destination_bucket" {
  description = "Nom du bucket de destination"
  value       = module.s3.destination_bucket_id
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda"
  value       = module.lambda.function_arn
}
