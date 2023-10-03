#this is for eks cluster

# main.tf

provider "aws" {
  region = "us-east-1"  # Modify with your desired region
}

module "vpc" {
  source = "./vpc"  # Path to your VPC Terraform configuration
}

module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.21"  # Modify with your desired EKS version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  worker_groups = {
    eks_nodes = {
      instance_type = "t2.micro"  # Modify with your desired instance type
      asg_max_size  = 1
    }
  }
}

output "eks_cluster_name" {
  value = module.eks_cluster.cluster_name
}
