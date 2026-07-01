module "source_bucket" {
  source = "./modules/s3"

  bucket_name = "${var.project_prefix}-source-images"
  tags = {
    Name = "${var.project_prefix}-source-images"
    Role = "source"
  }
}

module "dest_bucket" {
  source = "./modules/s3"

  bucket_name = "${var.project_prefix}-dest-pdfs"
  tags = {
    Name = "${var.project_prefix}-dest-pdfs"
    Role = "destination"
  }
}

module "lambda" {
  source = "./modules/lambda"

  function_name     = "${var.project_prefix}-image-to-pdf"
  source_bucket_arn = module.source_bucket.bucket_arn
  dest_bucket_name  = module.dest_bucket.bucket_name
  dest_bucket_arn   = module.dest_bucket.bucket_arn
  lambda_source_dir = "${path.module}/../lambda"

  tags = {
    Name = "${var.project_prefix}-image-to-pdf"
  }
}

resource "aws_s3_bucket_notification" "source_trigger" {
  bucket = module.source_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = module.lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = module.lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [module.lambda]
}
