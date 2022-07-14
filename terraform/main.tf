# Providers config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# AWS Provider docs
provider "aws" {
  region = var.aws_region
  profile = var.aws_credentials_profile
}

#Exposes resources
provider "archive" {}