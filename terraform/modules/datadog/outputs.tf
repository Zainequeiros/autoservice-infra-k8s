output "namespace" {
  value = kubernetes_namespace.datadog.metadata[0].name
}

output "release_name" {
  value = helm_release.datadog.name
}
