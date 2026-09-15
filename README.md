# Infraestrutura Kubernetes do Autoservice

Repositório de **Infraestrutura como Código (Terraform)** da camada de **rede, orquestração e edge** do Autoservice.

Nas Fases 1–2 a aplicação rodava em Kubernetes local (K3d/manifests no repo da app). Na **Fase 3** este repositório provisiona o caminho cloud: **VPC → EKS → ALB/Ingress → API Gateway**, além da rota serverless de autenticação e do Agent **Datadog**.

---

## Propósito

- Provisionar VPC (sub-redes públicas/privadas, NAT, security groups).
- Criar cluster **Amazon EKS** com node group escalável.
- Expor a API via **ALB / Ingress** e **Amazon API Gateway** (HTTP).
- Integrar `POST /auth/cpf` com a Lambda `cpf-auth` (`autoservice-lambda-auth`).
- Publicar outputs (SGs, subnets, URL do Gateway) consumidos pelo RDS e pela app.
- Instalar observabilidade no cluster ([`observability/`](observability/) — Datadog Agent).

### Ecossistema

| Repositório | Papel |
|-------------|--------|
| **autoservice-infra-k8s** (este) | Terraform EKS + API Gateway + Datadog |
| [autoservice](https://github.com/cristhian-ruescas/autoservice) | App Spring (`k8s/eks`) |
| [autoservice-lambda-auth](https://github.com/Zainequeiros/autoservice-lambda-auth) | Lambda de autenticação |
| [autoservice-infra-db](https://github.com/Zainequeiros/autoservice-infra-db) | RDS PostgreSQL |

Diagramas: [Miro — Autoservice](https://miro.com/app/board/uXjVHprBYf0=/).

---

## Tecnologias

| Item | Escolha |
|------|---------|
| IaC | Terraform 1.6+ |
| Cloud | AWS (`us-east-1` na Academy) |
| Cluster | Amazon EKS |
| Edge | API Gateway HTTP, VPC Link, ALB |
| Observabilidade | Datadog (Helm values em `observability/`) |
| Estado remoto | S3 + DynamoDB lock |
| CI/CD | GitHub Actions (`.github/workflows/terraform.yml`) |

**Dockerfile:** não se aplica (apenas Terraform + Helm values). Imagem da app: repo `autoservice`.

---

## Diagrama da arquitetura (este repositório)

```text
                    Internet
                        │
                        v
              +---------------------+
              | Amazon API Gateway  |
              |  · POST /auth/cpf   |------> Lambda cpf-auth
              |  · proxy APIs + JWT |         (outro repo)
              +----------+----------+
                         │ VPC Link / integração
                         v
              +---------------------+
              | ALB / Ingress       |
              | (subnets públicas)  |
              +----------+----------+
                         │
                         v
              +---------------------+
              | EKS (privado)       |
              |  autoservice-app    |---- JDBC ----> RDS (outro repo)
              |  Datadog Agent      |---- APM/logs -> Datadog
              +---------------------+
```

PNG com ícones oficiais AWS (frame no Miro / artefato na app):

- [Miro — Arquitetura AWS](https://miro.com/app/board/uXjVHprBYf0=/?moveToWidget=3458764683739809878)
- `autoservice/docs/observability/diagrams/autoservice-aws-architecture-corrigido.png`

Frame K8s (Ingress → Service → Deployment → HPA): [Miro — Kubernetes](https://miro.com/app/board/uXjVHprBYf0=/).

---

## Link Swagger / Postman

Este repositório **não** implementa APIs. Contratos:

| Recurso | Onde |
|---------|------|
| Swagger / OpenAPI | [autoservice](https://github.com/cristhian-ruescas/autoservice) — `/swagger-ui.html` |
| Postman | [Autoservice API.postman_collection.json](https://github.com/cristhian-ruescas/autoservice/blob/develop/Autoservice%20API.postman_collection.json) |
| Gateway (homolog) | output Terraform `api_gateway_url` após `apply` em `environments/homolog` |

Exemplo de uso após o Gateway estar no ar:

```http
POST https://<api_gateway_url>/auth/cpf
Content-Type: application/json

{"cpf":"52998224725"}
```

---

## Estrutura do repositório

```text
.github/workflows/terraform.yml
observability/                 # Datadog Agent (Helm values)
terraform/
  backend.hcl                  # exemplo / local (não versionar secrets)
  versions.tf
  modules/
    networking/
    eks/
    apigateway/
  environments/
    homolog/
    prod/
README.md
```

---

## Alinhamento ao desafio

- API Gateway + ALB + Ingress para roteamento público da aplicação.
- Rota `POST /auth/cpf` quando `auth_lambda_function_name` e `auth_lambda_invoke_arn` estão preenchidos.
- EKS com capacidade de escala (node group + HPA da app no repo `autoservice`).
- Security group `lambda_auth` + outputs de subnets/SG para liberar no RDS.
- Observabilidade: Datadog em [`observability/`](observability/).
- CI/CD Terraform; branches `develop` → homolog, `main` → prod.

---

## Pré-requisitos

- Conta AWS (ou Lab AWS Academy) com permissões adequadas
- Terraform 1.6+
- Bucket S3 + tabela DynamoDB para backend remoto
- Lambda `cpf-auth` já publicada (para ligar a rota de auth)
- kubectl (após o cluster existir) para Ingress Controller / app / Datadog

---

## Backend remoto

```bash
aws s3 mb s3://fiap-autoservice-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name fiap-autoservice-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

Use `terraform/backend.hcl` local (fora do versionamento de credenciais).

---

## Execução e deploy (Terraform)

```bash
cd terraform/environments/homolog
cp terraform.tfvars.example terraform.tfvars
# preencher VPC/conta, auth_lambda_*, etc.
terraform init -backend-config=../../backend.hcl   # ou backend.hcl local
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Produção: repetir em `terraform/environments/prod`.

### Outputs úteis

- `api_gateway_url`
- `load_balancer_dns_name`
- `lambda_auth_security_group_id`
- `eks_nodes_security_group_id`
- `private_subnet_ids`

Esses valores alimentam o `allowed_security_group_ids` do `autoservice-infra-db` e a configuração da Lambda em VPC.

### Pós-apply (app + observabilidade)

1. Ingress Controller no cluster (compatível com o Ingress da app).
2. Aplicar overlay EKS da app: `autoservice/k8s/eks`.
3. (Opcional) Instalar Datadog Agent com values em `observability/`.

---

## CI/CD

Workflow: **`.github/workflows/terraform.yml`** (`name: CI/CD Terraform`).

| Evento | Ação |
|--------|------|
| `pull_request` → `develop` / `main` | `fmt` + `validate` (homolog **e** prod) + `plan` |
| `push` → `develop` | validate + **Apply (homolog)** apenas |
| `push` → `main` | validate + **Apply (prod)** apenas |

`validate` nos dois ambientes em qualquer branch é **só checagem** (não aplica). Jobs de apply são separados — sem job fantasma de homolog na `main`.

Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`, `TERRAFORM_STATE_BUCKET`, `TERRAFORM_LOCK_TABLE`, `DD_API_KEY` (opcional).

> **Cuidado:** merge em `develop`/`main` dispara **apply**. Para só README, abra PR (validate/plan) e faça merge com Lab ativo.

---

## Observações

- Cluster em sub-redes privadas; entrada pública via API Gateway/ALB.
- Associação do ASG do node group ao Target Group do ALB pode exigir passo operacional pós-apply.
- Lab Academy: credenciais temporárias — renovar antes do CI de apply.

---

## Licença / uso acadêmico

Projeto do **Tech Challenge** (pós-graduação SOAT).
