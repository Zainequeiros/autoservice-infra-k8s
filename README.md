# autoservice-infra-k8s

Infraestrutura como código da camada de **rede, orquestração e edge** do Autoservice: VPC, EKS, ALB/Ingress, API Gateway e Agent Datadog.

## Propósito

- Provisionar VPC (sub-redes, NAT, security groups)
- Criar cluster Amazon EKS com node group
- Expor a API via ALB/Ingress e API Gateway HTTP
- Integrar `POST /auth/cpf` com a Lambda `cpf-auth`
- Publicar outputs (SGs, subnets, URL do Gateway) para RDS e apps
- Instalar observabilidade no cluster (`observability/` — Datadog Agent)

## Ecossistema

| Repositório | Papel |
|-------------|--------|
| **autoservice-infra-k8s** (este) | Terraform EKS + API Gateway + Datadog |
| `autoservice` / microsserviços | Deploy no cluster |
| `autoservice-lambda-auth` | Lambda de autenticação |
| `autoservice-infra-db` | RDS PostgreSQL |

## Tecnologias

| Item | Escolha |
|------|---------|
| IaC | Terraform |
| Cloud | AWS |
| Cluster | Amazon EKS |
| Edge | API Gateway HTTP, VPC Link, ALB |
| Observabilidade | Datadog |
| Estado remoto | S3 + DynamoDB lock |
| CI/CD | GitHub Actions (`.github/workflows/terraform.yml`) |

## Visão

```text
Internet
   │
   v
API Gateway  ──POST /auth/cpf──> Lambda cpf-auth
   │
   v
ALB / Ingress
   │
   v
EKS (apps + Datadog Agent) ──> RDS
```

## Execução

```bash
cd terraform/environments/homolog
cp terraform.tfvars.example terraform.tfvars
# preencher VPC, auth_lambda_*, etc.
terraform init -backend-config=../../backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Outputs úteis: `api_gateway_url`, `load_balancer_dns_name`, security groups e subnets.

Pós-apply: Ingress Controller, manifests das aplicações, Agent Datadog (`observability/`).

## CI/CD

| Evento | Ação |
|--------|------|
| Pull request | Test + Plan |
| Push `develop` | Deploy homolog |
| Push `main` | Deploy prod |

Secrets: AWS (inclui session token no Lab), state S3/DynamoDB, `DD_API_KEY` quando o Agent estiver habilitado.

> Credenciais do Lab Academy são temporárias — renove antes de apply.
