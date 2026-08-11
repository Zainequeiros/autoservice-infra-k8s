# Autoservice Infra K8s (Tech Challenge)

Repositório responsável pela **Infraestrutura Kubernetes com Terraform** (item 2 de 4 repositórios obrigatórios do desafio).

## Objetivo

Provisionar e manter, com Infraestrutura como Código, o ambiente Kubernetes da aplicação Autoservice com foco em:
- escalabilidade;
- alta disponibilidade;
- segurança;
- observabilidade;
- esteira CI/CD para homologação e produção.

## Escopo inicial deste repositório

Este repositório cobre:
- provisioning do cluster Kubernetes e componentes base;
- configuração de autoscaling (ex.: HPA);
- integração com observabilidade (Datadog ou New Relic);
- suporte ao roteamento/integração com API Gateway e serviços de autenticação;
- pipelines de validação e deploy com Terraform.

Não cobre:
- código da Function Serverless de autenticação (repositório 1);
- infraestrutura do banco gerenciado (repositório 3);
- código da aplicação principal (repositório 4).

## Requisitos obrigatórios refletidos no plano

- uso de Terraform para provisionamento;
- ambiente preparado para API Gateway + rotas protegidas via JWT/CPF;
- Kubernetes com escalabilidade;
- monitoramento de latência, consumo de recursos, healthchecks, logs estruturados e alertas;
- estratégia de branches protegidas e fluxo por Pull Request.

## Estrutura inicial

```text
terraform/
  modules/
  environments/
    homolog/
    prod/
.github/
  workflows/
```

## Estratégia de branches e deploy

- `master/main`: protegida, sem commits diretos;
- merges apenas por Pull Request;
- deploy automático para `homolog` e `prod` via workflow.

## Próximos incrementos técnicos

1. Definir provider e backend remoto do Terraform.
2. Criar módulos de rede, cluster e observabilidade.
3. Configurar pipelines de validação (`fmt`, `validate`, `plan`) e deploy (`apply`) por ambiente.
4. Publicar documentação arquitetural (diagramas, RFCs e ADRs) vinculada ao ecossistema completo dos 4 repositórios.
