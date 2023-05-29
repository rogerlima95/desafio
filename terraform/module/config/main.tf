locals {
  default_labels = {
    region = var.region
    environment  = var.environment
  }
}

/******************************************
  VPC configuration
 *****************************************/

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  for_each = {for vpc in var.vpc: vpc.control_vpc_id => vpc}
  name = each.value.name
  cidr = each.value.cidr

  azs             = try(each.value.azs, ["us-east-1a"])
  private_subnets = try(each.value.private_subnets, "")
  private_subnet_names = try(each.value.private_subnet_names, "")
  public_subnets  = each.value.public_subnets
  public_subnet_names = each.value.public_subnet_names
  intra_subnet_names = each.value.intra_subnet_names
  intra_subnets = each.value.intra_subnets
  enable_nat_gateway = try(each.value.enable_nat_gateway, "true")
  enable_vpn_gateway = try(each.value.enable_vpn_gateway, "false")

  tags = {
    Terraform = "true"
    Environment = var.environment
    control_vpc_id = each.value.control_vpc_id
  }
}

/******************************************
  EKS configuration
 *****************************************/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  for_each = {for eks in var.eks: eks.cluster_name => eks}
  cluster_name                    = each.value.cluster_name
  cluster_version                 = each.value.cluster_version
  cluster_endpoint_private_access = try(each.value.cluster_endpoint_private_access, true)
  cluster_endpoint_public_access  = try(each.value.cluster_endpoint_public_access, true)
  cluster_addons = {
  coredns = {
    most_recent = try(each.value.coredns_most_recent, true)
  }
  kube-proxy = {
    most_recent = try(each.value.kube-proxy_most_recent, true)
  }
  vpc-cni = {
    most_recent = try(each.value.vpc-cni_most_recent, true)
  }
}
  vpc_id                   = try(each.value.vpc_id, module.vpc[each.value.control_vpc_id].vpc_id)
  subnet_ids               = try(each.value.subnet_ids, module.vpc[each.value.control_vpc_id].private_subnets)
  control_plane_subnet_ids = try(each.value.control_plane_subnet_ids, module.vpc[each.value.control_vpc_id].intra_subnets)

  eks_managed_node_group_defaults = {
    instance_types = try(each.value.default_instance_types, [])
  }

  eks_managed_node_groups = each.value.eks_managed_node_groups 
  tags = {
    Terraform = "true"
    Environment = var.environment
    control_vpc_id = try(each.value.control_vpc_id, "")
  }

}

/******************************************
  ECR configuration
 *****************************************/

resource "aws_ecr_repository" "app_repository" {
  name = var.repository_name
}

resource "aws_ecr_repository_policy" "app_repository_policy" {
  repository = aws_ecr_repository.app_repository.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPushPull",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }
  ]
}
EOF
}


/******************************************
  ECR setup
 *****************************************/


data "aws_ecr_authorization_token" "token" {
}

resource "null_resource" "docker_push" {
  depends_on = [ module.eks ]
  triggers = {
    registry_id = data.aws_ecr_authorization_token.token.authorization_token
  }

  provisioner "local-exec" {
    command = "docker build -t ${aws_ecr_repository.app_repository.repository_url}:latest -f ../../../app/Dockerfile ../../../app/"
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_ecr_authorization_token.token.proxy_endpoint}"
    environment = {
      DOCKER_CONFIG = "~/.docker"
    }
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.app_repository.repository_url}:latest"
  }

    provisioner "local-exec" {
    command = "aws eks --region us-east-1 update-kubeconfig --name eks-desafio"
    }
}