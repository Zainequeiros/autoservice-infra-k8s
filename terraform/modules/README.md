# Módulos Terraform

Módulos reutilizáveis da infraestrutura Kubernetes:

- `network`: VPC, subnets e tags de cluster;
- `eks`: cluster EKS, managed node groups e addons base;
- `gateway`: Traefik + metrics-server para expor a aplicação, suportar HPA e HTTPS opcional com ACM;
- `observability`: log group do plano de controle, dashboard e alertas técnicos e de métricas de negócio.
