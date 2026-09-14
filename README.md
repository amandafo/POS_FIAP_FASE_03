# ToggleMaster — Tech Challenge Fase 3

Evolução do ToggleMaster da Fase 2 para uma plataforma com Infraestrutura como Código, CI/DevSecOps e entrega contínua por GitOps.

## Microsserviços

| Serviço | Tecnologia | Função |
|---|---|---|
| `auth-service` | Go | Validação e administração de chaves de API |
| `flag-service` | Python/Flask | Gerenciamento de feature flags |
| `targeting-service` | Python/Flask | Regras de segmentação |
| `evaluation-service` | Go | Avaliação das flags, cache e publicação de eventos |
| `analytics-service` | Python/Flask | Consumo dos eventos e persistência analítica |

## Objetivo desta fase

- provisionar a AWS com Terraform e state remoto no S3;
- usar a `LabRole` existente do AWS Academy, sem criar IAM;
- testar código e dependências dos cinco serviços;
- bloquear vulnerabilidades críticas;
- publicar imagens no ECR com tag do commit;
- manter manifests em `gitops/`;
- deixar o ArgoCD sincronizar o EKS automaticamente.

## Executar localmente

Pré-requisito: Docker com Compose.

```bash
make local-up
make health
make e2e
```

Encerrar:

```bash
make local-down
```

Executar testes unitários em containers:

```bash
make test
```

Executar verificações locais:

```bash
make lint
make sast
make sca
make terraform-check
```

## Estado atual

A base local foi copiada com segurança e o fluxo E2E está funcional. A infraestrutura AWS ainda não foi criada. O andamento completo está em `TODO.md`.

## Segurança

- Credenciais e secrets não são versionados.
- O arquivo sensível da Fase 2 não foi copiado.
- O guia operacional privado é ignorado pelo Git.
- IDs, endpoints e credenciais da conta AWS anterior não fazem parte da nova configuração.

## Entrega esperada

- repositório com Terraform, workflows, serviços e manifests GitOps;
- vídeo de demonstração de até 20 minutos;
- relatório com participantes, links, decisões, dificuldades e estimativa de custos.
