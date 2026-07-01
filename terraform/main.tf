# ---------------------------------------------------------------------------
# Module S3 : bucket source + bucket destination
# ---------------------------------------------------------------------------
module "s3" {
  source = "./modules/s3"

  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
}

# ---------------------------------------------------------------------------
# Module Lambda : fonction + rôle IAM + permissions S3/logs
# ---------------------------------------------------------------------------
module "lambda" {
  source = "./modules/lambda"

  function_name           = var.lambda_function_name
  package_path            = var.lambda_package_path
  source_bucket_arn       = module.s3.source_bucket_arn
  destination_bucket_arn  = module.s3.destination_bucket_arn
  destination_bucket_name = module.s3.destination_bucket_name
  aws_region              = var.aws_region
}

# ---------------------------------------------------------------------------
# Câblage S3 -> Lambda (au niveau racine pour éviter un cycle entre modules)
# ---------------------------------------------------------------------------

# Autorise le service S3 à invoquer la fonction
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.source_bucket_arn
}

# Déclenchement de la Lambda à chaque création d'objet dans le bucket source
resource "aws_s3_bucket_notification" "source_trigger" {
  bucket = module.s3.source_bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
