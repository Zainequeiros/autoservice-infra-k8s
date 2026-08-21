module "network" {
  source = "../../modules/network"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "cluster" {
  source = "../../modules/eks"

  cluster_name                         = local.name
  cluster_version                      = var.cluster_version
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cloudwatch_log_retention_days        = var.cloudwatch_log_retention_days
  vpc_id                               = module.network.vpc_id
  subnet_ids                           = module.network.private_subnet_ids
  node_instance_types                  = var.node_instance_types
  node_min_size                        = var.node_min_size
  node_max_size                        = var.node_max_size
  node_desired_size                    = var.node_desired_size
  tags                                 = local.common_tags
}

module "observability" {
  source = "../../modules/observability"

  aws_region                    = var.aws_region
  autoservice_namespace         = "autoservice"
  autoservice_service_name      = "autoservice-app"
  cluster_name                  = local.name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  tags                          = local.common_tags
}

module "gateway" {
  source = "../../modules/gateway"

  ingress_class_name       = var.gateway_ingress_class_name
  is_default_ingress_class = var.gateway_is_default_ingress_class
  load_balancer_scheme     = var.gateway_load_balancer_scheme
  acm_certificate_arn      = var.gateway_acm_certificate_arn
  force_https_redirect     = var.gateway_force_https_redirect
  service_annotations      = var.gateway_service_annotations

  depends_on = [module.cluster]
}
