resource "aws_cloudwatch_log_group" "eks_control_plane" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = var.tags
}

resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${var.cluster_name}-node-cpu-high"
  alarm_description   = "Uso medio de CPU dos nodes acima de 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${var.cluster_name}-node-memory-high"
  alarm_description   = "Uso medio de memoria dos nodes acima de 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_pods_low" {
  alarm_name          = "${var.cluster_name}-${var.autoservice_service_name}-pods-low"
  alarm_description   = "Quantidade de pods em execucao da aplicacao abaixo do esperado."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 1
  metric_name         = "service_number_of_running_pods"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = var.autoservice_namespace
    Service     = var.autoservice_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_latency_high" {
  alarm_name          = "${var.cluster_name}-api-latency-high"
  alarm_description   = "Latencia media da API acima do limite esperado."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.api_latency_alarm_threshold_ms
  metric_name         = var.api_latency_metric_name
  namespace           = var.business_metrics_namespace
  period              = 300
  statistic           = "Average"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "healthcheck_success_rate_low" {
  alarm_name          = "${var.cluster_name}-healthcheck-success-rate-low"
  alarm_description   = "Taxa de sucesso de healthcheck abaixo do limite esperado."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = var.healthcheck_success_rate_alarm_threshold
  metric_name         = var.healthcheck_success_rate_metric_name
  namespace           = var.business_metrics_namespace
  period              = 300
  statistic           = "Average"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "order_processing_failures" {
  alarm_name          = "${var.cluster_name}-order-processing-failures"
  alarm_description   = "Falhas no processamento de ordens de servico acima do limite esperado."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.order_processing_failures_alarm_threshold
  metric_name         = var.order_processing_failures_metric_name
  namespace           = var.business_metrics_namespace
  period              = 300
  statistic           = "Sum"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "cluster" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "text"
        x          = 0
        y          = 0
        width      = 24
        height     = 6
        properties = {
          markdown = <<-EOT
          # ${var.cluster_name}

          Dashboard operacional com foco em cluster, autoscaling e saúde da aplicação `autoservice`.
          EOT
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "CPU media dos nodes"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Memoria media dos nodes"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Pods em execucao - autoservice"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            [
              "ContainerInsights",
              "service_number_of_running_pods",
              "ClusterName",
              var.cluster_name,
              "Namespace",
              var.autoservice_namespace,
              "Service",
              var.autoservice_service_name
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Restarts de containers"
          region  = var.aws_region
          stat    = "Sum"
          period  = 300
          view    = "timeSeries"
          metrics = [
            ["ContainerInsights", "pod_number_of_container_restarts", "ClusterName", var.cluster_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          title   = "Latencia media da API (ms)"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            [var.business_metrics_namespace, var.api_latency_metric_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          title   = "Healthcheck success rate (%)"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            [var.business_metrics_namespace, var.healthcheck_success_rate_metric_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 8
        height = 6
        properties = {
          title   = "Volume diario de ordens"
          region  = var.aws_region
          stat    = "Sum"
          period  = 86400
          view    = "timeSeries"
          metrics = [
            [var.business_metrics_namespace, var.order_volume_daily_metric_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 24
        width  = 8
        height = 6
        properties = {
          title   = "Tempo medio por status"
          region  = var.aws_region
          stat    = "Average"
          period  = 300
          view    = "timeSeries"
          metrics = [
            [var.business_metrics_namespace, var.order_execution_time_metric_name, "Status", "Diagnostico"],
            [".", ".", "Status", "Execucao"],
            [".", ".", "Status", "Finalizacao"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 24
        width  = 8
        height = 6
        properties = {
          title   = "Erros de integracao"
          region  = var.aws_region
          stat    = "Sum"
          period  = 300
          view    = "timeSeries"
          metrics = [
            [var.business_metrics_namespace, var.integration_errors_metric_name]
          ]
        }
      }
    ]
  })
}
