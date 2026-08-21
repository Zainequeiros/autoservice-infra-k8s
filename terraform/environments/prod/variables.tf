variable "project_name" {
  description = "Nome base do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente do deploy."
  type        = string
}

variable "aws_region" {
  description = "Regiao AWS."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs publicos."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs privados."
  type        = list(string)
}

variable "cluster_version" {
  description = "Versao do Kubernetes."
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_public_access" {
  description = "Habilita endpoint publico do cluster."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs autorizados a acessar o cluster."
  type        = list(string)
  default     = []

  validation {
    condition = (
      !var.cluster_endpoint_public_access ||
      (
        length(var.cluster_endpoint_public_access_cidrs) > 0 &&
        !contains(var.cluster_endpoint_public_access_cidrs, "0.0.0.0/0")
      )
    )
    error_message = "Quando endpoint publico estiver habilitado, informe CIDRs especificos e nunca use 0.0.0.0/0."
  }
}

variable "node_instance_types" {
  description = "Tipos de instancia dos workers."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Numero minimo de workers."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Numero maximo de workers."
  type        = number
  default     = 6
}

variable "node_desired_size" {
  description = "Numero desejado de workers."
  type        = number
  default     = 3
}

variable "cloudwatch_log_retention_days" {
  description = "Retencao dos logs do cluster."
  type        = number
  default     = 90
}

variable "gateway_ingress_class_name" {
  description = "IngressClass usada pela aplicacao no gateway."
  type        = string
  default     = "traefik"
}

variable "gateway_is_default_ingress_class" {
  description = "Define se a IngressClass do gateway sera a classe default do cluster."
  type        = bool
  default     = false
}

variable "gateway_load_balancer_scheme" {
  description = "Tipo de exposicao do load balancer do gateway."
  type        = string
  default     = "internet-facing"
}

variable "gateway_acm_certificate_arn" {
  description = "ARN do certificado ACM para HTTPS no gateway."
  type        = string
  default     = null
  nullable    = true
}

variable "gateway_force_https_redirect" {
  description = "Forca redirecionamento HTTP -> HTTPS no gateway quando certificado for informado."
  type        = bool
  default     = true
}

variable "gateway_service_annotations" {
  description = "Anotacoes extras do Service do gateway."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
