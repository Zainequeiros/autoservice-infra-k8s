# ADR 003 - Estrategia de Observabilidade

## Status

Aceito

## Contexto

O desafio exige visibilidade de cluster e de negocio (ordens de servico, latencia, uptime e falhas).

## Decisao

- Baseline de infraestrutura: CloudWatch + Container Insights.
- Alertas tecnicos: CPU, memoria e pods.
- Alertas de aplicacao/negocio: metricas customizadas publicadas no namespace `Autoservice`.
- Dashboard unificado com metricas tecnicas e de negocio.

## Consequencias

- Positivas:
  - Observabilidade centralizada no ecossistema AWS.
  - Menor atrito para operacao inicial do projeto.
  - Escalabilidade para adicionar novas metricas sem alterar topologia base.
- Atencoes:
  - Metrica de negocio depende de instrumentacao nos repositorios `autoservice` e `autoservice-lambda-auth`.
  - Sem instrumentacao da aplicacao, parte dos widgets/alarmes fica sem dados.
