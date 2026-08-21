output "vpc_id" {
  value = module.network.vpc_id
}

output "cluster_name" {
  value = module.cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.cluster.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.cluster.node_security_group_id
}

output "oidc_provider_arn" {
  value = module.cluster.oidc_provider_arn
}

output "dashboard_name" {
  value = module.observability.dashboard_name
}

output "alerts_topic_arn" {
  value = module.observability.alerts_topic_arn
}

output "gateway_namespace" {
  value = module.gateway.namespace
}

output "gateway_service_name" {
  value = module.gateway.service_name
}

output "gateway_ingress_class_name" {
  value = module.gateway.ingress_class_name
}

output "gateway_load_balancer_hostname" {
  value = module.gateway.load_balancer_hostname
}

output "gateway_base_url" {
  value = module.gateway.base_url
}
