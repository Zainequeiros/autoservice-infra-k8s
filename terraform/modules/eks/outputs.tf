output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Nome do cluster criado."
}

output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "ARN do cluster."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint do cluster."
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Certificado CA do cluster."
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security group do cluster."
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "Security group dos workers."
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "OIDC provider do cluster."
}
