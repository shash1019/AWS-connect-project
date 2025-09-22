terraform {
  required_version = ">= 1.6.0"
  backend "s3" {}  # your workflow already passes backend-config
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.50" }
  }
}
provider "aws" { region = var.aws_region }