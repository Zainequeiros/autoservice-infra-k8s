# ADR 002 - Uso de EKS Managed Node Groups

## Status

Aceito

## Contexto

Era necessario suportar escalabilidade com menor custo operacional de manutencao.

## Decisao

Utilizar managed node groups do EKS com parametros de escala por ambiente.

## Consequencias

- Positivas:
  - Atualizacoes e operacao de nos simplificadas.
  - Parametrizacao clara de min/max/desired por ambiente.
  - Menor risco operacional do que gestao manual de ASGs e bootstrap.
- Atencoes:
  - Ajustes de capacidade devem ser calibrados por carga real.
  - Requer monitoramento continuo de CPU/memoria/pods para tuning.
