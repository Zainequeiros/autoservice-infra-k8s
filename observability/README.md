# Observabilidade no EKS (Datadog)

Instalação do Agent:

```powershell
helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl create namespace datadog --dry-run=client -o yaml | kubectl apply -f -
kubectl -n datadog create secret generic datadog-secret --from-literal api-key=$env:DD_API_KEY
helm upgrade --install datadog-agent datadog/datadog `
  -n datadog `
  -f observability/datadog-values.yaml
```

Ajuste `datadog.clusterName` e `datadog.site` em [`datadog-values.yaml`](./datadog-values.yaml) conforme o ambiente.

A aplicação Spring Boot (`autoservice/k8s/eks`) envia traces/logs quando `DD_API_KEY` e o Agent estão configurados. Dashboards e monitors versionados ficam em `autoservice/docs/observability/`.
