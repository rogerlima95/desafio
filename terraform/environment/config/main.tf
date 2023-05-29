locals {
  region = "us-east-1"
  environment = "desafio"
}

module "config" {
    source = "../../module/config"
    region = local.region
    environment = local.environment
    repository_name = "app_repository"

    vpc = [
      { 
          control_vpc_id = "vpc-desafio"
          name = "vpc-desafio"
          cidr = "10.0.0.0/16"
          azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]
          private_subnet_names = ["private-subnet1", "private-subnet2", "private-subnet3" ]
          private_subnets = ["10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22"]
          public_subnet_names =["public-subnet1", "public-subnet2", "public-subnet3" ]
          public_subnets  = ["10.0.16.0/24", "10.0.20.0/24", "10.0.24.0/24"]
          intra_subnet_names = ["intra-subnet1", "intra-subnet2", "intra-subnet3"]
          intra_subnets = ["10.0.28.0/24", "10.0.32.0/24", "10.0.36.0/24"]
          
          }
    ]


    eks = [
      {
        control_vpc_id = "vpc-desafio"
        cluster_name = "eks-desafio"
        cluster_version = "1.26"
        default_instance_types = ["t2.medium","t3.medium"]
        eks_managed_node_groups = {
            spots = {
            min_size     = 3
            max_size     = 3
            desired_size = 3
      
            instance_types = ["t2.medium","t3.medium"]
            capacity_type  = "SPOT"
          }
         }
        tags = {
           Environment = "desafio"
           Terraform   = "true"
         }
      }
    ]
}