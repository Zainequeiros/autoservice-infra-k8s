# Infraestrutura Kubernetes do Autoservice

Este repositório provisiona a camada de orquestração e rede da aplicação Autoservice com Terraform, cobrindo:
- VPC e sub-redes públicas/privadas;
- cluster Kubernetes na AWS (EKS);
- ingress principal via Application Load Balancer;
- API Gateway HTTP integrado ao cluster por VPC Link;
- backend remoto do Terraform com S3 + DynamoDB;
- pipeline de CI/CD com validação e deploy automatizado.

## Visão geral da arquitetura

A infraestrutura é organizada em três camadas:
1. Rede pública: Internet Gateway, sub-redes públicas e ALB.
2. Rede privada: sub-redes privadas e NAT Gateway para o cluster.
3. Orquestração: EKS com node group escalável, ingress e exposição por API Gateway.

Diagrama da arquitetura:

```text
          Internet
             |
             v
      +---------------------+
      | API Gateway HTTP    |
      | (VPC Link + route)  |
      +----------+----------+
                 |
                 v
      +---------------------+
      | ALB / Ingress       |
      | (public subnet)     |
      +----------+----------+
                 |
                 v
      +---------------------+
      | EKS Cluster         |
      | Node Group          |
      |  + Ingress Nginx/   |
      |  AWS LoadBalancer   |
      +---------------------+
``` 

Fluxo sugerido:
- cliente acessa a API Gateway;
- API Gateway encaminha a requisição por VPC Link para o ALB;
- o ingress/controller dentro do cluster distribui para os serviços Kubernetes;
- o cluster roda em sub-redes privadas, conectando-se à internet via NAT.

## Estrutura do repositório

```text
.github/
  workflows/
    terraform-ci.yml
terraform/
  backend.hcl
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

## Alinhamento ao desafio corporativo

A infraestrutura deste repositório foi desenhada para suportar o desafio operacional da oficina:

- API Gateway + ALB + Ingress para roteamento seguro e público da aplicação principal.
- Cluster EKS com escalabilidade horizontal e clusterização para múltiplas unidades.
- Rede privada, subnets, NAT, IAM e políticas para ambiente seguro e resiliente.
- Observabilidade centralizada com métricas de CPU, memória, latência, healthchecks e logs estruturados.
- Deploy automatizado em ambientes homolog e prod com Terraform, PR obrigatório e CI/CD em GitHub Actions.
- Integração com Datadog para dashboards de uptime, latência, falhas e volume de ordens.

## Requisitos para execução

Antes de aplicar a infraestrutura, você deve ter:
- conta AWS com acesso válido;
- Terraform 1.6+ instalado;
- bucket S3 para o estado do Terraform;
- tabela DynamoDB para lock do Terraform;
- papel IAM com permissões para criar VPC, EKS, ALB e API Gateway.

## Configuração do backend remoto

O estado remoto é configurado por `backend "s3"` dentro de cada ambiente.

Exemplo de criação do backend:

```bash
aws s3 mb s3://fiap-autoservice-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name fiap-autoservice-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

A configuração do backend também pode ser reutilizada pelo arquivo `terraform/backend.hcl`.

## Execução do Terraform

1. Faça o login na AWS:

```bash
aws configure
```

2. Inicialize o ambiente desejado:

```bash
cd terraform/environments/homolog
terraform init -backend-config="../../backend.hcl"
```

3. Verifique o plano:

```bash
terraform plan -var-file=terraform.tfvars.example.example
```

4. Aplique a infraestrutura:

```bash
terraform apply -var-file=terraform.tfvars.example.example
```

Para produção, repita os passos em `terraform/environments/prod`.

## Pipeline CI/CD

O workflow em `.github/workflows/terraform-ci.yml` executa:
- `terraform fmt -check -recursive` em pull requests;
- `terraform init -backend=false` e `terraform validate` para cada ambiente;
- `terraform plan` na abertura do PR;
- `terraform apply` após merge para `main`.

O processo usa autenticação AWS com OIDC e variáveis do repositório (`AWS_REGION`, `TF_STATE_BUCKET` e `TF_STATE_LOCK_TABLE`).

## Observações

- O cluster é provisionado em sub-redes privadas, com acesso público apenas via API Gateway/ALB;
- a arquitetura foi desenhada para suportar alta disponibilidade e escalabilidade;
- o backend remoto garante consistência e lock do estado do Terraform;
- a estrutura foi feita para facilitar a expansão do projeto com ingress controller, observabilidade e políticas de segurança.

## Links de deploy ativos

- Endpoint público da API: configure via ALB/Ingress em `https://api.autoservice.example.com`
- Ambiente de homologação: `https://homolog-api.autoservice.example.com`
- Ambiente de produção: `https://api.autoservice.example.com`
- Observabilidade: dashboards Datadog com latência, CPU, memória, healthchecks e ordens por status.
