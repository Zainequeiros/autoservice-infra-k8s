# RFC 002 - Contrato de Integracao de Autenticacao

## Contexto

As rotas sensiveis devem ser protegidas por autenticacao via CPF com emissao de JWT em function serverless.

## Decisao

- Gateway neste repositorio: Traefik no EKS
- Emissao/validacao de token: `autoservice-lambda-auth`
- Consumo do token e autorizacao de rotas: `autoservice`
- Banco de clientes: `autoservice-infra-db`

## Contrato tecnico

1. Cliente chama endpoint de autenticacao por CPF.
2. Lambda valida CPF e status no banco.
3. Lambda emite JWT com claims necessarias.
4. Cliente usa JWT nas APIs protegidas da aplicacao.
5. Aplicacao valida JWT e processa a requisicao.

## Responsabilidades deste repositorio

- Garantir canal de entrada (gateway) e exposicao controlada.
- Entregar outputs para integracao entre repositorios.
- Entregar base de observabilidade para o fluxo.
