terraform {
  required_version = ">= 1.6, <= 1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}