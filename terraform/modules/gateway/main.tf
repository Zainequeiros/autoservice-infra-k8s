locals {
  tls_annotations = var.acm_certificate_arn == null ? {} : {
    "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"     = var.acm_certificate_arn
    "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"    = "443"
    "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "tcp"
  }

  redirect_arguments = (
    var.acm_certificate_arn != null && var.force_https_redirect
  ) ? [
    "--entrypoints.web.http.redirections.entryPoint.to=websecure",
    "--entrypoints.web.http.redirections.entryPoint.scheme=https"
  ] : []

  service_annotations = merge(
    {
      "service.beta.kubernetes.io/aws-load-balancer-type"                         = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                       = var.load_balancer_scheme
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
    },
    local.tls_annotations,
    var.service_annotations
  )
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  values = [
    yamlencode({
      args = [
        "--kubelet-preferred-address-types=InternalIP,Hostname",
        "--metric-resolution=15s"
      ]
    })
  ]
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"     = var.release_name
      "app.kubernetes.io/part-of"  = "autoservice-platform"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "traefik" {
  name       = var.release_name
  namespace  = kubernetes_namespace.this.metadata[0].name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  values = [
    yamlencode({
      additionalArguments = [
        "--api.dashboard=false",
        "--entrypoints.web.address=:80",
        "--entrypoints.websecure.address=:443"
      ] ++ local.redirect_arguments
      deployment = {
        podAnnotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9100"
        }
      }
      ingressClass = {
        enabled        = true
        isDefaultClass = var.is_default_ingress_class
        name           = var.ingress_class_name
      }
      logs = {
        access = {
          enabled = true
          format  = "json"
        }
        general = {
          format = "json"
          level  = "INFO"
        }
      }
      metrics = {
        prometheus = {
          enabled = true
        }
      }
      ports = {
        web = {
          port        = 8000
          exposedPort = 80
          expose = {
            default = true
          }
        }
        websecure = {
          port        = 8443
          exposedPort = 443
          expose = {
            default = true
          }
        }
      }
      providers = {
        kubernetesIngress = {
          publishedService = {
            enabled = true
          }
        }
      }
      service = {
        annotations = local.service_annotations
        type        = "LoadBalancer"
      }
    })
  ]

  depends_on = [helm_release.metrics_server]
}

data "kubernetes_service_v1" "gateway" {
  metadata {
    name      = var.release_name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  depends_on = [helm_release.traefik]
}
