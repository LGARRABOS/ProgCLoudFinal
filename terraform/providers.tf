provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.assume_role_arn
    session_name = "ynov-iac-2025"
  }

  default_tags {
    tags = {
      Project = var.project_tag
    }
  }
}
