terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  backend "s3" {
    bucket         = "fiap-autoservice-terraform-state"
    key            = "autoservice-infra-k8s/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "fiap-autoservice-terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "eks" {
  source = "../../modules/eks"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  cluster_version             = var.cluster_version
  vpc_id                      = module.networking.vpc_id
  private_subnet_ids          = module.networking.private_subnet_ids
  public_subnet_ids           = module.networking.public_subnet_ids
  eks_nodes_security_group_id = module.networking.eks_nodes_security_group_id
  node_group_instance_type    = var.node_group_instance_type
  node_group_desired_capacity = var.node_group_desired_capacity
  node_group_min_size         = var.node_group_min_size
  node_group_max_size         = var.node_group_max_size
}

module "apigateway" {
  source = "../../modules/apigateway"

  project_name                      = var.project_name
  environment                       = var.environment
  aws_region                        = var.aws_region
  vpc_id                            = module.networking.vpc_id
  public_subnet_ids                 = module.networking.public_subnet_ids
  ingress_security_group_id         = module.networking.alb_security_group_id
  node_group_autoscaling_group_name = module.eks.node_group_autoscaling_group_name
}
