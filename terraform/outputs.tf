output "source_bucket_name" {
  description = "Nom du bucket source"
  value       = module.source_bucket.bucket_name
}

output "dest_bucket_name" {
  description = "Nom du bucket destination"
  value       = module.dest_bucket.bucket_name
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda"
  value       = module.lambda.function_arn
}

output "lambda_role_arn" {
  description = "ARN du rôle IAM Lambda"
  value       = module.lambda.role_arn
}
