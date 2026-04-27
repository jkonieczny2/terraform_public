terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  # Backend values live in backend.s3.tfbackend (see backend.s3.tfbackend.example). Init with:
  #   terraform init -backend-config=backend.s3.tfbackend
  backend "s3" {}
}

provider "aws" {
  region = "us-east-2"
  alias  = "us-east-2"
}
