variable "project_name" {
  description = "Project name used in Datadog tags."
  type        = string
}

variable "environment" {
  description = "Environment tag (homolog, prod)."
  type        = string
}

variable "dd_api_key" {
  description = "Datadog API key for the Agent."
  type        = string
  sensitive   = true
}

variable "dd_site" {
  description = "Datadog site (datadoghq.com, datadoghq.eu, etc.)."
  type        = string
  default     = "datadoghq.com"
}

variable "chart_version" {
  description = "Pinned version of the official Datadog Helm chart."
  type        = string
  default     = "3.88.0"
}
