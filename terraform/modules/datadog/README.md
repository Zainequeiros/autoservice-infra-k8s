# Módulo Datadog Agent (EKS)

Instala o [Datadog Helm chart](https://docs.datadoghq.com/containers/kubernetes/installation/?tab=helm) no cluster EKS via Terraform.

## Uso

```hcl
module "datadog" {
  source = "../../modules/datadog"

  project_name = var.project_name
  environment  = var.environment
  dd_api_key   = var.dd_api_key
  dd_site      = var.dd_site

  depends_on = [module.eks]
}
```

## Recursos criados

- Namespace `datadog`
- Secret `datadog-secret` (API key)
- Helm release com APM, logs de containers e DogStatsD (`nonLocalTraffic`)

## Pré-requisitos

Providers `kubernetes` e `helm` configurados com credenciais do cluster EKS (ver `environments/*/providers.tf`).
