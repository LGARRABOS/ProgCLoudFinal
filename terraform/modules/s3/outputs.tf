output "bucket_id" {
  description = "ID du bucket S3"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Nom du bucket S3"
  value       = aws_s3_bucket.this.bucket
}
