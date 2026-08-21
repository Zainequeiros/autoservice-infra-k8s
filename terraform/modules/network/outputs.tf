output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID da VPC criada."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Subnets publicas da VPC."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Subnets privadas da VPC."
}
