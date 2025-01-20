################################################################################
# Versions of Terraform and various providers required by project
################################################################################

terraform {
  required_version = ">= 1.7.5, <= 1.7.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.1"
    }
  }
}
