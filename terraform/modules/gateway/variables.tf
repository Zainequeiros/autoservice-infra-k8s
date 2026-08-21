variable "namespace" {
  description = "Namespace do gateway/ingress."
  type        = string
  default     = "gateway-system"
}

variable "release_name" {
  description = "Nome do release Helm do gateway."
  type        = string
  default     = "traefik"
}

variable "ingress_class_name" {
  description = "IngressClass usada pela aplicacao."
  type        = string
  default     = "traefik"
}

variable "is_default_ingress_class" {
  description = "Define se a IngressClass do gateway sera a classe default do cluster."
  type        = bool
  default     = false
}

variable "load_balancer_scheme" {
  description = "Scheme do load balancer do gateway."
  type        = string
  default     = "internet-facing"
}

variable "acm_certificate_arn" {
  description = "ARN do certificado ACM para habilitar HTTPS no load balancer do gateway."
  type        = string
  default     = null
  nullable    = true
}

variable "force_https_redirect" {
  description = "Forca redirecionamento HTTP -> HTTPS no Traefik quando HTTPS estiver habilitado."
  type        = bool
  default     = true
}

variable "service_annotations" {
  description = "Anotacoes extras do Service do gateway."
  type        = map(string)
  default     = {}
}
