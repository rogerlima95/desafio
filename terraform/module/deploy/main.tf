locals {
  default_labels = {
    region = var.region
    environment  = var.environment
  }
}

/******************************************
  k8s setup
 *****************************************/

 data "aws_ecr_repository" "app_repository" {
  name = var.repository_name
}

resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(templatefile("${path.module}/files/deployment.yaml.tpl",{
    IMAGE     = "${data.aws_ecr_repository.app_repository.repository_url}:latest"
  }))
}

resource "kubernetes_manifest" "service" {
  manifest = yamldecode(file("${path.module}/files/svc.yaml.tpl"))
}
