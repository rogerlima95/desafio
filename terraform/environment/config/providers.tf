terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
#  backend "s3" {
#    bucket = "tfstate-config"
#    key    = "tfstate-config"
#    region = "us-east-1"
#
#  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}