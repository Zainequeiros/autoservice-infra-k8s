variable "cluster_name" {
  description = "Nome do cluster monitorado."
  type        = string
}

variable "aws_region" {
  description = "Regiao AWS usada nos widgets do dashboard."
  type        = string
}

variable "autoservice_namespace" {
  description = "Namespace da aplicacao principal."
  type        = string
  default     = "autoservice"
}

variable "autoservice_service_name" {
  description = "Service da aplicacao principal."
  type        = string
  default     = "autoservice-app"
}

variable "cloudwatch_log_retention_days" {
  description = "Retencao dos logs do plano de controle."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags padrao da infraestrutura."
  type        = map(string)
  default     = {}
}

variable "business_metrics_namespace" {
  description = "Namespace CloudWatch para metricas de negocio/publicadas pela aplicacao."
  type        = string
  default     = "Autoservice"
}

variable "api_latency_metric_name" {
  description = "Nome da metrica de latencia da API."
  type        = string
  default     = "ApiLatencyMs"
}

variable "healthcheck_success_rate_metric_name" {
  description = "Nome da metrica de sucesso de healthcheck/uptime da aplicacao."
  type        = string
  default     = "HealthcheckSuccessRate"
}

variable "order_volume_daily_metric_name" {
  description = "Nome da metrica de volume diario de ordens."
  type        = string
  default     = "OrderVolumeDaily"
}

variable "order_execution_time_metric_name" {
  description = "Nome da metrica de tempo de execucao das ordens."
  type        = string
  default     = "OrderExecutionTimeSeconds"
}

variable "integration_errors_metric_name" {
  description = "Nome da metrica de erros de integracao."
  type        = string
  default     = "IntegrationErrors"
}

variable "order_processing_failures_metric_name" {
  description = "Nome da metrica de falhas no processamento de ordens."
  type        = string
  default     = "OrderProcessingFailures"
}

variable "api_latency_alarm_threshold_ms" {
  description = "Limite de alerta para latencia media da API em milissegundos."
  type        = number
  default     = 800
}

variable "healthcheck_success_rate_alarm_threshold" {
  description = "Limite minimo de sucesso do healthcheck em percentual."
  type        = number
  default     = 99
}

variable "order_processing_failures_alarm_threshold" {
  description = "Limite de alerta para falhas no processamento de ordens."
  type        = number
  default     = 0
}
