# Relatório de Entrega — Tech Challenge Fase 3

## Participantes

- Amanda Ferreira de Oliveira - RM371484

## Links

- Repositório: https://github.com/amandafo/POS_FIAP_FASE_03
- Vídeo: **[PREENCHER APÓS A PUBLICAÇÃO DO VÍDEO]**
- Documentação: README do repositório.

## Resumo da solução

O ToggleMaster foi implantado como cinco microsserviços em um cluster Amazon EKS. Toda a infraestrutura foi declarada em módulos Terraform e o state foi armazenado em um bucket S3 remoto com criptografia, versionamento, bloqueio público e lock.

A solução contém duas subnets públicas e duas privadas, três bancos PostgreSQL no RDS, Redis no ElastiCache, DynamoDB, SQS com fila de erro e cinco repositórios ECR. O ambiente usa a `LabRole` existente do AWS Academy e não cria recursos IAM.

Os pipelines executam testes, lint, SAST, análise de dependências, build e scan de container. Vulnerabilidades críticas bloqueiam a publicação. Imagens aprovadas são publicadas no ECR com o SHA do commit, e o pipeline altera a mesma tag nos manifests GitOps.

O ArgoCD monitora a pasta `gitops/` e sincroniza os cinco serviços automaticamente. Senhas e chaves ficam no AWS Secrets Manager e são entregues ao Kubernetes pelo External Secrets Operator.

## Decisões técnicas

- Monorepo com uma pasta GitOps, opção permitida pelo enunciado.
- Nodes, RDS e Redis em subnets privadas.
- Uma NAT Gateway para reduzir custo no laboratório.
- Bancos Single-AZ e instâncias pequenas para homologação.
- Tags imutáveis baseadas no SHA; não é usada a tag `latest`.
- External Secrets para impedir a inclusão de senhas em YAML.
- Credenciais temporárias sincronizadas por comando por causa da restrição IAM do AWS Academy.

## Dificuldades e soluções

### Autenticação dos pods no AWS Academy

O Academy não permite criar as roles necessárias para IRSA. Além disso, o External Secrets não conseguiu obter credenciais pelo metadata service do node. A solução foi criar um Secret Kubernetes temporário por comando, sem arquivo YAML versionado. Esse Secret é renovado sempre que a sessão do laboratório muda.

### Cache do Helm no Terraform em Docker

O container não possuía um diretório de cache gravável. O wrapper do Terraform passou a configurar o cache do Helm em `/tmp` dentro do container.

### Vulnerabilidades nas imagens Python

O Trivy encontrou três vulnerabilidades críticas corrigíveis no pacote `perl-base` da imagem-base. Os Dockerfiles foram alterados para aplicar as atualizações de segurança do sistema durante o build. Depois disso, os três scans foram aprovados.

## Evidências registradas

- [`evidencias/infraestrutura-validada.txt`](evidencias/infraestrutura-validada.txt)
- [`evidencias/pipeline-seguranca.txt`](evidencias/pipeline-seguranca.txt)
- [`evidencias/gitops-e2e.txt`](evidencias/gitops-e2e.txt)
- [`evidencias/e2e-aws-detalhado.txt`](evidencias/e2e-aws-detalhado.txt)

Execução bloqueada pelo Trivy:
https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916194667

Execução aprovada após a correção:
https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916382484

## Comprovações visuais

As imagens abaixo foram registradas em `docs/evidencias/prints/`. O caminho utilizado para chegar a cada tela está explicado em [`GUIA_COMPROVACOES_FASE_03.md`](GUIA_COMPROVACOES_FASE_03.md).

Antes de anexar uma imagem, é necessário conferir se ela não mostra credenciais, tokens, senhas, valores de secrets ou outras informações sensíveis.

### Código e funcionamento local

#### Estrutura do repositório

A estrutura do repositório comprova a entrega dos cinco microsserviços, dos módulos Terraform, dos workflows do GitHub Actions e dos manifests GitOps.

![Estrutura do repositório com serviços, Terraform, workflows e GitOps](evidencias/prints/01-repositorio-estrutura.png)

#### Teste integrado local

O teste local comprova que autenticação, criação da flag, regra de segmentação, avaliação, fila e armazenamento de analytics funcionam de forma integrada.

![Teste E2E executado no ambiente local](evidencias/prints/02-teste-local-e2e.png)
![Teste E2E executado no ambiente local](evidencias/prints/02-teste-local-e2e-1.png)
![Teste E2E executado no ambiente local](evidencias/prints/02-teste-local-e2e-2.png)
[`E2E logs`](evidencias/prints/02-teste-local-e2e-logs.txt)


### Infraestrutura como Código e AWS

#### Terraform plan

O resultado do `terraform plan` comprova que a infraestrutura está declarada como código e corresponde ao ambiente provisionado.

![Resultado do Terraform plan](evidencias/prints/03-terraform-plan-0.png)
![Resultado do Terraform plan](evidencias/prints/03-terraform-plan-1.png)


#### State remoto no S3

O bucket S3 armazena o state remoto com criptografia, versionamento, bloqueio público e lock, evitando que o `terraform.tfstate` seja mantido apenas na máquina local.

![State remoto do Terraform armazenado no S3](evidencias/prints/04-s3-state-remoto.png)

#### Rede da aplicação

O mapa de recursos da VPC comprova a criação de duas subnets públicas, duas privadas, tabelas de rotas, Internet Gateway e NAT Gateway em duas zonas de disponibilidade.

![Mapa da VPC com subnets, rotas, Internet Gateway e NAT Gateway](evidencias/prints/05-vpc-resource-map.png)

#### Cluster EKS

O cluster `togglemaster-cluster` executa os microsserviços no Kubernetes e utiliza a `LabRole` existente do AWS Academy.

![Cluster EKS ativo](evidencias/prints/06-eks-cluster.png)


#### Node Group

O Managed Node Group fornece a capacidade computacional do cluster com dois nodes implantados nas subnets privadas.

![Managed Node Group e nodes do EKS](evidencias/prints/07-eks-nodes.png)


#### Bancos PostgreSQL

Foram criadas três instâncias PostgreSQL no RDS, separadas para autenticação, flags e regras de segmentação.

![Três bancos PostgreSQL disponíveis no RDS](evidencias/prints/08-rds-bancos.png)


#### Redis

O Redis no ElastiCache é utilizado pelo serviço de avaliação como cache para reduzir o tempo de resposta.

![Redis disponível no Amazon ElastiCache](evidencias/prints/09-elasticache-redis.png)


#### DynamoDB

A tabela `ToggleMasterAnalytics` armazena os eventos produzidos durante as avaliações das feature flags.

![Tabela ToggleMasterAnalytics ativa no DynamoDB](evidencias/prints/10-dynamodb-tabela.png)


#### SQS e fila de erro

A fila `togglemaster-events` recebe os eventos de avaliação. A fila `togglemaster-events-dlq` recebe mensagens que não puderem ser processadas depois das tentativas configuradas.

![Fila SQS e fila de mensagens mortas](evidencias/prints/11-sqs-filas.png)


#### Repositórios ECR

Cada microsserviço possui seu próprio repositório privado de imagens no Amazon ECR.

![Cinco repositórios dos microsserviços no ECR](evidencias/prints/12-ecr-repositorios.png)


#### Imagem identificada pelo SHA

As imagens aprovadas são publicadas usando o SHA completo do commit como tag. A tag `latest` não é utilizada nos deployments.

![Imagem publicada no ECR com tag baseada no SHA](evidencias/prints/13-ecr-imagem-sha.png)

(Para gerar este print: em **ECR → Repositories**, abra `evaluation-service` e mostre uma imagem cuja tag começa com `7edbee1`, ocultando o ID da conta se a entrega for pública.)

#### Secrets Manager

Senhas de bancos e chaves da aplicação são armazenadas no AWS Secrets Manager e entregues ao Kubernetes pelo External Secrets Operator.

![Lista de secrets do ToggleMaster no Secrets Manager](evidencias/prints/14-secrets-manager.png)

(Para gerar este print: Console AWS → **Secrets Manager** → **Secrets**; filtre por `togglemaster/homolog` e mostre apenas os nomes, sem clicar em **Retrieve secret value**.)

### Pipeline DevSecOps

#### Pipelines aprovados

Os cinco microsserviços possuem workflows próprios. Eles executam testes, lint, SAST, SCA, build e scan da imagem antes da publicação.

![Pipelines dos cinco microsserviços aprovados](evidencias/prints/15-pipelines-sucesso-auth.png)
![Pipelines dos cinco microsserviços aprovados](evidencias/prints/15-pipelines-sucesso-analytics.png)
![Pipelines dos cinco microsserviços aprovados](evidencias/prints/15-pipelines-sucesso-evaluation.png)
![Pipelines dos cinco microsserviços aprovados](evidencias/prints/15-pipelines-sucesso-flag.png)
![Pipelines dos cinco microsserviços aprovados](evidencias/prints/15-pipelines-sucesso-targeting.png)


#### Bloqueio por vulnerabilidade crítica

Uma alteração temporária em Pull Request removeu uma atualização de segurança. O Trivy encontrou três vulnerabilidades críticas e bloqueou o pipeline no scan da imagem. Essa alteração não foi integrada à branch `main`.

![Pipeline bloqueado pelo Trivy por vulnerabilidades críticas](evidencias/prints/16-pipeline-bloqueado.png)


#### Pipeline aprovado depois da correção

Depois de restaurar a atualização de segurança, todos os testes e verificações foram aprovados.

![Pipeline aprovado depois da correção de segurança](evidencias/prints/17-pipeline-corrigido.png)

### GitOps, ArgoCD e execução no Kubernetes

#### Commit automático do GitOps

Depois de publicar uma imagem aprovada, o GitHub Actions altera o arquivo GitOps correspondente e cria um commit automático usando `github-actions[bot]`.

![Commit automático de atualização do GitOps](evidencias/prints/18-gitops-commit.png)


#### Atualização da tag no GitOps

O arquivo `kustomization.yaml` passa a apontar para a imagem do ECR usando o mesmo SHA produzido pelo pipeline.

![Tag da imagem atualizada no arquivo GitOps](evidencias/prints/19-gitops-tag-sha.png)

(Para gerar este print: GitHub → **Code** → `gitops/apps/evaluation-service/kustomization.yaml`; mostre `newName` e `newTag` com o SHA, ocultando o ID da conta.)

#### Sincronização pelo ArgoCD

O ArgoCD monitora a pasta GitOps e sincroniza automaticamente a aplicação raiz e os cinco microsserviços. Todos devem aparecer como `Synced` e `Healthy`.

![Aplicação raiz e cinco microsserviços sincronizados no ArgoCD](evidencias/prints/20-argocd-aplicacoes-01.png)

![Aplicação raiz e cinco microsserviços sincronizados no ArgoCD](evidencias/prints/20-argocd-aplicacoes-02.png)

#### Pods em execução

Os pods comprovam que os manifests sincronizados pelo ArgoCD foram aplicados ao EKS. O serviço de avaliação possui duas réplicas, totalizando seis pods das aplicações.

![Pods dos microsserviços em execução no EKS](evidencias/prints/21-kubernetes-pods.png)

#### Teste integrado na AWS

O teste E2E executado no ambiente AWS verifica os cinco health checks, configura uma flag e sua regra, avalia um usuário e confirma o processamento do evento.

![Teste E2E completo executado no ambiente AWS](evidencias/prints/22-e2e-aws-01.png)
![Teste E2E completo executado no ambiente AWS](evidencias/prints/22-e2e-aws-02.png)
![Teste E2E completo executado no ambiente AWS](evidencias/prints/22-e2e-aws-03.png)
![Teste E2E completo executado no ambiente AWS](evidencias/prints/22-e2e-aws-04.png)
![Teste E2E completo executado no ambiente AWS](evidencias/prints/22-e2e-aws-05.png)

#### Evento de analytics no DynamoDB

O item final no DynamoDB comprova que o evento saiu do serviço de avaliação, passou pelo SQS, foi consumido pelo serviço de analytics e chegou ao armazenamento definitivo.

![Evento do teste E2E armazenado no DynamoDB](evidencias/prints/23-dynamodb-evento.png)


## Estimativa de custos

A estimativa de custos do ambiente de homologação foi criada no AWS Pricing Calculator. Ela reúne os serviços utilizados pelo projeto e apresenta os custos previstos para a execução da infraestrutura na região `us-east-1`.

O resultado exportado apresenta custo inicial estimado de **US$ 180,00**, custo mensal estimado de **US$ 397,90** e custo total estimado de **US$ 4.954,80** para 12 meses. Os valores servem como referência de planejamento e podem variar conforme os preços e o consumo real dos serviços.

Os arquivos completos da estimativa estão disponíveis nos seguintes formatos:

- [Estimativa detalhada em JSON](<evidencias/ToggleMaster - Ambiente de Homologação AWS.json>);
- [Estimativa exportada em PDF](<ToggleMaster - Homologacao.pdf>).

![Resumo da estimativa no AWS Pricing Calculator](evidencias/prints/24-pricing-calculator.png)

Para consultar a versão interativa, acesse a [estimativa compartilhada no AWS Pricing Calculator](https://calculator.aws/#/estimate?id=e5aa62adc88442cfef1fd080f53da37a9416e875).
