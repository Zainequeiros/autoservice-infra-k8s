variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
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
  description = "CIDRs autorizados a acessar o endpoint do cluster."
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

variable "cloudwatch_log_retention_days" {
  description = "Retencao dos logs do plano de controle."
  type        = number
  default     = 30
}

variable "vpc_id" {
  description = "VPC onde o cluster sera criado."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas usadas pelo cluster."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Tipos de instancia dos nos."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Numero minimo de nos."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Numero maximo de nos."
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Numero desejado de nos."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags padrao da infraestrutura."
  type        = map(string)
  default     = {}
}
