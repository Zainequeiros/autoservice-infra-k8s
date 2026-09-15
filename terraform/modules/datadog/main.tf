resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
    labels = {
      app         = "datadog"
      project     = var.project_name
      environment = var.environment
    }
  }
}

resource "kubernetes_secret" "api_key" {
  metadata {
    name      = "datadog-secret"
    namespace = kubernetes_namespace.datadog.metadata[0].name
  }

  data = {
    "api-key" = var.dd_api_key
  }

  type = "Opaque"
}

resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = kubernetes_namespace.datadog.metadata[0].name
  version    = var.chart_version

  values = [
    yamlencode({
      datadog = {
        apiKeyExistingSecret    = kubernetes_secret.api_key.metadata[0].name
        apiKeyExistingSecretKey = "api-key"
        site                    = var.dd_site
        tags                    = ["env:${var.environment}", "project:${var.project_name}"]
        apm = {
          portEnabled = true
        }
        logs = {
          enabled             = true
          containerCollectAll = true
        }
        processAgent = {
          enabled = true
        }
        dogstatsd = {
          nonLocalTraffic = true
        }
      }
      clusterAgent = {
        enabled = true
      }
      agents = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_secret.api_key]
}
