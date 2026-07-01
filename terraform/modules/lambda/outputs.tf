output "function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.this.arn
}

output "role_arn" {
  description = "ARN du rôle IAM Lambda"
  value       = aws_iam_role.lambda.arn
}

output "invoke_arn" {
  description = "ARN d'invocation Lambda"
  value       = aws_lambda_function.this.invoke_arn
}
