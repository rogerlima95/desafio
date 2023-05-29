locals {
  region = "us-east-1"
  environment = "desafio"
}

module "deploy" {
  repository_name = "app_repository"
  environment = local.environment
  region = local.region
  source = "../../module/deploy"
}