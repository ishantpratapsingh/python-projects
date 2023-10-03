# main.tf

provider "aws" {
  region = "us-east-1"  # Modify with your AWS region
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

resource "kubernetes_namespace" "exercise" {
  metadata {
    name = "exercise"
  }
}

resource "kubernetes_deployment" "hello_world" {
  metadata {
    name      = "hello-world"
    namespace = kubernetes_namespace.exercise.metadata.0.name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hello-world"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-world"
        }
      }

      spec {
        container {
          name  = "hello-world"
          image = "your-dockerhub-username/hello-world-app:latest"  # Replace with your Docker Hub image name
          ports {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello_world" {
  metadata {
    name      = "hello-world"
    namespace = kubernetes_namespace.exercise.metadata.0.name
  }

  spec {
    selector = {
      app = "hello-world"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

output "service_endpoint" {
  value = kubernetes_service.hello_world.status.0.load_balancer_ingress.0.hostname
}
