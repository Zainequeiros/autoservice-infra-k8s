# ADR 001 - Uso do Traefik como API Gateway/Ingress

## Status

Aceito

## Contexto

Era necessario adotar um gateway para roteamento de entrada das APIs em Kubernetes.

## Decisao

Utilizar Traefik instalado via Helm, com exposicao por AWS Load Balancer.

## Consequencias

- Positivas:
  - Integracao simples com Kubernetes.
  - Configuracao de IngressClass clara para a aplicacao.
  - Suporte a logs estruturados e metricas Prometheus.
- Atencoes:
  - HTTPS depende de certificado ACM por ambiente.
  - Requer hardening de exposicao e revisao continua das regras de borda.
