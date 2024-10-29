# provider.tf

provider "aws" {
  region  = "ap-south-1" # specify the region you prefer
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
