variable "name" {
  description = "Nome base da VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade utilizadas pela VPC."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets publicas."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas."
  type        = list(string)
}

variable "tags" {
  description = "Tags padrao da infraestrutura."
  type        = map(string)
  default     = {}
}
