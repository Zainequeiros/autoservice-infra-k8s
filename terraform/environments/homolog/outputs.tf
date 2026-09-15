output "vpc_id" {
  value = module.networking.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "api_gateway_url" {
  value = module.apigateway.api_gateway_url
}

output "load_balancer_dns_name" {
  value = module.apigateway.load_balancer_dns_name
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_nodes_security_group_id" {
  value = module.networking.eks_nodes_security_group_id
}

output "lambda_auth_security_group_id" {
  value = module.networking.lambda_auth_security_group_id
}

output "datadog_namespace" {
  description = "Kubernetes namespace where the Datadog Agent is installed."
  value       = try(module.datadog[0].namespace, null)
}
