# autoservice-infra-k8s — Fase 3/4

Infraestrutura como código da camada de **rede, orquestração e edge**: VPC, EKS, ALB/Ingress, API Gateway e Agent Datadog.

Usada na **Fase 3** (cloud) e na **Fase 4** (hospeda os microsserviços da saga + mesh).

## Qualidade / CI

| Item | Status |
|------|--------|
| IaC | Terraform (mt + alidate no CI) |
| CI/CD | .github/workflows/terraform.yml — Plan em PR; apply por branch |
| Observabilidade | Datadog Agent (Helm module ou manifests kubectl) |

## Propósito

- Provisionar VPC (sub-redes, NAT, security groups)
- Criar cluster Amazon EKS com node group
- Expor a API via ALB/Ingress e API Gateway HTTP
- Integrar POST /auth/cpf com a Lambda cpf-auth
- Publicar outputs (SGs, subnets, URL do Gateway) para RDS e apps
- Instalar observabilidade no cluster

## Ecossistema

| Repositório | Papel |
|-------------|--------|
| **autoservice-infra-k8s** (este) | Terraform EKS + API Gateway + Datadog |
| utoservice-os / illing / execucao | Deploy no EKS (Fase 4) |
| utoservice-lambda-auth | Lambda de autenticação |
| utoservice-infra-db | RDS PostgreSQL |

## Tecnologias

| Item | Escolha |
|------|---------|
| IaC | Terraform |
| Cloud | AWS (Academy Lab ok) |
| Cluster | Amazon EKS |
| Edge | API Gateway HTTP, VPC Link, ALB |
| Observabilidade | Datadog |
| Estado remoto | S3 + DynamoDB lock |

## Visão

`	ext
Internet
   │
   v
API Gateway  ──POST /auth/cpf──> Lambda cpf-auth
   │
   v
ALB / Ingress / ELB dos MS
   │
   v
EKS (OS + Billing + Execução + mesh + Datadog Agent) ──> RDS / Postgres mesh
`

## Execução

`ash
cd terraform/environments/homolog
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=../../backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
`

Outputs: pi_gateway_url, load_balancer_dns_name, SGs e subnets.

Datadog sem Helm: [observability/datadog-kubectl/README.md](observability/datadog-kubectl/README.md).

## CI/CD

| Evento | Ação |
|--------|------|
| Pull request | Test + Plan |
| Push develop | Deploy homolog |
| Push main | Deploy prod |

Secrets: AWS (session token no Lab), state S3/DynamoDB, DD_API_KEY quando o Agent estiver habilitado.

> Credenciais do Lab Academy são temporárias — renove antes de apply. Ao terminar a demo, desired do node group = 0.
