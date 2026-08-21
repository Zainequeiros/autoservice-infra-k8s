output "log_group_name" {
  value       = aws_cloudwatch_log_group.eks_control_plane.name
  description = "Nome do log group do plano de controle."
}

output "alerts_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN do topico de alertas."
}

output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.cluster.dashboard_name
  description = "Nome do dashboard criado."
}
