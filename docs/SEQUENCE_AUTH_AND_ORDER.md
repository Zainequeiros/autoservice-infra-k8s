# Diagrama de Sequencia - Autenticacao e Abertura de Ordem

```mermaid
sequenceDiagram
    autonumber
    participant Cliente
    participant Gateway as API Gateway (Traefik)
    participant Lambda as autoservice-lambda-auth
    participant DB as Banco Gerenciado
    participant App as autoservice (K8s)
    participant Obs as CloudWatch

    Cliente->>Gateway: POST /auth/cpf {cpf}
    Gateway->>Lambda: Encaminha requisicao de autenticacao
    Lambda->>DB: Valida existencia/status do cliente
    DB-->>Lambda: Cliente valido
    Lambda-->>Gateway: JWT assinado
    Gateway-->>Cliente: 200 + token

    Cliente->>Gateway: POST /orders (Authorization: Bearer JWT)
    Gateway->>App: Encaminha para rota protegida
    App->>DB: Persiste ordem de servico
    DB-->>App: Ordem criada
    App-->>Gateway: 201 Created
    Gateway-->>Cliente: Resposta final

    App->>Obs: Publica metricas (latencia, volume, erros, status)
    Lambda->>Obs: Publica metricas/logs de autenticacao
```

## Observacoes

- Este repositorio cobre infraestrutura K8s/gateway/observabilidade base.
- A validacao de CPF, emissao de JWT e regras de autorizacao sao implementadas nos repositorios `autoservice-lambda-auth` e `autoservice`.
