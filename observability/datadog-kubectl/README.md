# Datadog no EKS — só kubectl (sem Helm) — Fase 3/4

Caminho usado na demo da **Fase 4** quando o Helm do Academy falha (AV).

## 1. API Key (você cola)

No Datadog da equipe: **Organization Settings → API Keys**.

```powershell
kubectl apply -f 00-namespace.yaml

kubectl -n datadog create secret generic datadog-secret `
  --from-literal=api-key=COLE_SUA_API_KEY_AQUI `
  --dry-run=client -o yaml | kubectl apply -f -
```

Se a org for **EU**, depois edite `02-agent-daemonset.yaml` e troque `DD_SITE` para `datadoghq.eu`.

## 2. Instalar o Agent

Na pasta deste README:

```powershell
cd C:\Users\crist\Projetos\autoservice-infra-k8s\observability\datadog-kubectl
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-rbac.yaml
kubectl apply -f 02-agent-daemonset.yaml
kubectl -n datadog get pods -w
```

Espere `1/1 Running` em cada nó.

## 3. Ligar trace nos microsserviços

```powershell
foreach ($ns in @('autoservice-os','autoservice-billing','autoservice-execucao')) {
  kubectl -n $ns patch configmap $ns --type merge -p "{`"data`":{`"DD_TRACE_ENABLED`":`"true`",`"DD_LOGS_INJECTION`":`"true`",`"DD_METRICS_EXPORT`":`"true`",`"DD_ENV`":`"homolog`",`"DD_SERVICE`":`"$ns`"}}"
  kubectl -n $ns rollout restart deploy/$ns
}
```

## 4. Conferir no Datadog

1. Gere tráfego no Lab (fluxo de OS).
2. **Infrastructure → Hosts** — nós do EKS.
3. **APM → Services** — `autoservice-os`, `billing`, `execucao`.
4. **Logs** — `env:homolog` + `correlation_id:...`.

## Remover

```powershell
kubectl delete -f 02-agent-daemonset.yaml
kubectl delete -f 01-rbac.yaml
kubectl delete secret datadog-secret -n datadog
kubectl delete -f 00-namespace.yaml
```
