# RFC 001 - Escolha de Cloud e IaC

## Contexto

O Tech Challenge exige alta disponibilidade, escalabilidade, CI/CD e provisionamento por infraestrutura como codigo.

## Decisao

- Cloud: AWS
- Orquestracao: Amazon EKS
- IaC: Terraform com separacao por modulos e ambientes (`homolog` e `prod`)
- Pipeline: GitHub Actions com `validate` em PR e `plan/apply` em push de ambiente

## Justificativa

- EKS reduz overhead operacional do control plane Kubernetes.
- Terraform permite reproducao e rastreabilidade de ambientes.
- Estrutura modular reduz acoplamento e facilita manutencao.
- Pipelines automatizadas melhoram governanca e reduzem erro manual.

## Impactos

- Necessidade de governanca de secrets e OIDC no GitHub Actions.
- Necessidade de alinhamento com repositorios `autoservice`, `autoservice-lambda-auth` e `autoservice-infra-db`.
