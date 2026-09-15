# ToggleMaster — Tech Challenge Fase 3

Evolução do ToggleMaster para uma plataforma de microsserviços com infraestrutura criada por Terraform, pipelines DevSecOps e deploy automático por GitOps.

## Arquitetura

O projeto contém cinco serviços:

| Serviço | Tecnologia | Responsabilidade |
|---|---|---|
| `auth-service` | Go | Cria e valida chaves de API |
| `flag-service` | Python/Flask | Gerencia feature flags |
| `targeting-service` | Python/Flask | Gerencia regras de segmentação |
| `evaluation-service` | Go | Avalia flags, usa Redis e publica eventos no SQS |
| `analytics-service` | Python/Flask | Consome o SQS e grava eventos no DynamoDB |

Na AWS, o Terraform cria VPC, duas subnets públicas, duas privadas, NAT Gateway, EKS com node group, três RDS PostgreSQL, Redis, DynamoDB, SQS com DLQ, cinco ECR e segredos no Secrets Manager. O state fica em um bucket S3 remoto.

O projeto usa a `LabRole` já fornecida pelo AWS Academy. Nenhuma role ou policy IAM é criada pelo Terraform.

## Fluxo de entrega

1. Um Pull Request executa testes, lint, SAST, SCA, build e scan da imagem.
2. Vulnerabilidades críticas impedem a publicação.
3. Um push aprovado na `main` publica a imagem no ECR usando o SHA do commit.
4. O pipeline altera a tag em `gitops/apps/<serviço>/kustomization.yaml`.
5. O ArgoCD detecta o commit e sincroniza automaticamente o EKS.

Não é usada a tag `latest` nos deployments.

## Executar localmente

Pré-requisito: Docker com Compose.

```bash
make local-up
make health
make e2e
make local-down
```

Validações locais:

```bash
make test
make lint
make sast
make sca
make terraform-check
```

## Trabalhar com o AWS Academy

As credenciais temporárias devem ser salvas em `credentials_aws_academy.txt`, que está no `.gitignore`. Para carregá-las:

```bash
source scripts/aws-academy-env.sh
aws sts get-caller-identity
```

Sempre que a sessão for renovada, sincronize a credencial temporária usada pelo External Secrets e pelos dois serviços que acessam SQS/DynamoDB:

```bash
./scripts/sync-academy-k8s-credentials.sh
```

Terraform é executado em Docker:

```bash
source scripts/aws-academy-env.sh
./scripts/terraform-docker.sh init -backend-config="bucket=<BUCKET_DO_STATE>"
./scripts/terraform-docker.sh plan
./scripts/terraform-docker.sh apply
```

O arquivo local ignorado `infra/terraform.tfvars` mantém `install_platform = true` depois da primeira instalação. Em uma conta nova, faça primeiro a infraestrutura com `false` e somente depois instale os charts com `true`.

## GitOps e ArgoCD

Os manifests estão em `gitops/`. Para cadastrar a aplicação raiz:

```bash
kubectl apply -f gitops/argocd/root-application.yaml
kubectl get applications -n argocd
```

Para abrir a interface:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Acesse `http://localhost:8080`. A senha inicial deve ser consultada diretamente no cluster e nunca adicionada ao repositório.

## Segurança

- Credenciais, states, planos Terraform e arquivos de variáveis locais são ignorados pelo Git.
- Senhas dos bancos e chaves das aplicações ficam no AWS Secrets Manager.
- O External Secrets entrega os valores ao Kubernetes sem secrets em YAML.
- Como o AWS Academy não permite criar IAM, as credenciais temporárias dos workloads são sincronizadas por comando e precisam ser renovadas junto com a sessão.
- As imagens rodam como usuário não root e com capabilities removidas.

## Acompanhamento

O estado detalhado das atividades está em [`TODO.md`](TODO.md). O relatório de entrega está em [`docs/RELATORIO_ENTREGA.md`](docs/RELATORIO_ENTREGA.md).
