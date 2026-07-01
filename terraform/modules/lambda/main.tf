data "aws_caller_identity" "current" {}

# --- Rôle d'exécution ------------------------------------------------------

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# --- Permissions : S3 (lecture source / écriture destination) + logs -------

data "aws_iam_policy_document" "lambda" {
  statement {
    sid       = "ReadSource"
    actions   = ["s3:GetObject"]
    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    sid       = "WriteDestination"
    actions   = ["s3:PutObject"]
    resources = ["${var.destination_bucket_arn}/*"]
  }

  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

# --- Groupe de logs (rétention explicite) ----------------------------------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# --- Fonction --------------------------------------------------------------

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda.arn
  runtime          = var.runtime
  handler          = "handler.handler"
  filename         = var.package_path
  source_code_hash = filebase64sha256(var.package_path)
  timeout          = 30
  memory_size      = 512

  environment {
    variables = {
      DESTINATION_BUCKET = var.destination_bucket_name
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda,
    aws_cloudwatch_log_group.lambda,
  ]
}
