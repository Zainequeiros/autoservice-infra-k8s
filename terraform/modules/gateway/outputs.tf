output "namespace" {
  value       = kubernetes_namespace.this.metadata[0].name
  description = "Namespace do gateway."
}

output "service_name" {
  value       = var.release_name
  description = "Nome do Service exposto pelo gateway."
}

output "ingress_class_name" {
  value       = var.ingress_class_name
  description = "IngressClass a ser usada pelos manifests da aplicacao."
}

output "load_balancer_hostname" {
  value       = try(data.kubernetes_service_v1.gateway.status[0].load_balancer[0].ingress[0].hostname, null)
  description = "Hostname publico do load balancer do gateway."
}

output "base_url" {
  value       = try("${var.acm_certificate_arn != null ? "https" : "http"}://${data.kubernetes_service_v1.gateway.status[0].load_balancer[0].ingress[0].hostname}", null)
  description = "Base URL inicial para expor a aplicacao."
}
