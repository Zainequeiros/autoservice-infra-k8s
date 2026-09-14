# Secrets GitHub — Datadog

## autoservice-infra-k8s

| Secret | Obrigatório | Uso |
|--------|-------------|-----|
| `DD_API_KEY` | Sim (quando `enable_datadog_agent = true`) | `TF_VAR_dd_api_key` no workflow Terraform |

```powershell
gh secret set DD_API_KEY -R Zainequeiros/autoservice-infra-k8s
# Cole a API key quando solicitado (Organization Settings → API Keys no Datadog)
```

## autoservice-lambda-auth

| Secret | Obrigatório | Uso |
|--------|-------------|-----|
| `DD_API_KEY` | Sim (para traces na Lambda) | Deploy Serverless |
| `DD_TRACE_ENABLED` | Opcional | `true` para habilitar APM na Lambda |

```powershell
gh secret set DD_API_KEY -R Zainequeiros/autoservice-lambda-auth
gh secret set DD_TRACE_ENABLED -R Zainequeiros/autoservice-lambda-auth --body "true"
```

## autoservice (app)

A aplicação no EKS **não** precisa de `DD_API_KEY` no pod — apenas o Agent no cluster. Opcionalmente, para importar monitors/dashboard via CI no futuro:

| Secret | Uso |
|--------|-----|
| `DD_APP_KEY` | Scripts `import-datadog-*.ps1` (Application Key) |
