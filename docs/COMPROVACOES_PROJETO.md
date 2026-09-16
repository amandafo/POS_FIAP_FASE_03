# Comprovações do projeto — Tech Challenge Fase 3

Este documento consolida as evidências produzidas durante a implementação e a validação do ToggleMaster na Fase 3. Os registros demonstram o funcionamento local, o provisionamento da infraestrutura na AWS, a segurança dos pipelines, a entrega por GitOps e a execução integrada dos microsserviços no Amazon EKS.

O ambiente foi implantado no AWS Academy, na região `us-east-1`, respeitando a restrição de utilizar a `LabRole` existente e sem criar roles ou policies IAM.

## Resultado consolidado

| Área | Resultado realizado |
|---|---|
| Microsserviços | Cinco serviços integrados: autenticação, flags, targeting, avaliação e analytics |
| Ambiente local | Docker Compose, cinco health checks, testes unitários e fluxo E2E aprovados |
| Infraestrutura | Recursos provisionados por Terraform organizado em módulos |
| Estado do Terraform | State remoto no S3 com criptografia, versionamento e lock |
| Kubernetes | EKS ativo, dois nodes `Ready` e seis pods das aplicações em execução |
| Dados | Três RDS PostgreSQL, Redis, DynamoDB, SQS e DLQ disponíveis |
| Imagens | Cinco repositórios ECR com tags baseadas no SHA do commit |
| Segurança | Testes, lint, SAST, SCA e scan de container aplicados nos pipelines |
| Bloqueio | Vulnerabilidades críticas impediram a continuidade de uma execução de demonstração |
| GitOps | Atualização automática dos manifests e sincronização pelo ArgoCD |
| Teste AWS | Fluxo completo aprovado, incluindo SQS, analytics e DynamoDB |
| Custos | Estimativa criada e exportada pelo AWS Pricing Calculator |

## Código e funcionamento local

O repositório reúne os cinco microsserviços, os módulos Terraform, os workflows do GitHub Actions, os manifests Kubernetes e a configuração GitOps. Essa organização mantém aplicação, infraestrutura e automação no mesmo histórico de mudanças.

![Estrutura do repositório](evidencias/prints/01-repositorio-estrutura.png)

O ambiente local foi executado com Docker Compose. Os cinco health checks responderam corretamente e o teste integrado percorreu autenticação, criação da flag, definição da regra, avaliação do usuário, mensageria e armazenamento do evento no DynamoDB Local.

![Execução local integrada — início](evidencias/prints/02-teste-local-e2e.png)

![Execução local integrada — validações](evidencias/prints/02-teste-local-e2e-1.png)

![Execução local integrada — resultado](evidencias/prints/02-teste-local-e2e-2.png)

O registro textual completo dessa execução está disponível em [logs do E2E local](evidencias/prints/02-teste-local-e2e-logs.txt).

## Infraestrutura como código

O Terraform foi estruturado nos módulos `network`, `eks`, `databases`, `messaging`, `ecr` e `platform`. O plano final não apresentou diferenças entre o código e o ambiente provisionado, confirmando que a infraestrutura implantada correspondia à configuração versionada.

![Terraform plan — recursos verificados](evidencias/prints/03-terraform-plan-0.png)

![Terraform plan — infraestrutura sem alterações](evidencias/prints/03-terraform-plan-1.png)

O state remoto foi armazenado em um bucket S3. O backend utiliza criptografia e arquivo de lock, evitando que o controle da infraestrutura dependa apenas da máquina local.

![State remoto do Terraform no S3](evidencias/prints/04-s3-state-remoto.png)

## Rede AWS

A rede foi criada em duas zonas de disponibilidade. Ela contém duas subnets públicas, duas privadas, tabelas de rotas, Internet Gateway e NAT Gateway. Os nodes do EKS, os bancos e o Redis foram mantidos nas subnets privadas.

![Mapa de recursos da VPC](evidencias/prints/05-vpc-resource-map.png)

## Amazon EKS

O cluster `togglemaster-cluster` foi provisionado com a `LabRole` do AWS Academy e permaneceu em estado ativo. O Managed Node Group foi configurado com dois nodes para executar as aplicações e os componentes da plataforma.

![Cluster EKS ativo](evidencias/prints/06-eks-cluster.png)

![Managed Node Group e nodes](evidencias/prints/07-eks-nodes.png)

## Bancos, cache e mensageria

Foram implantadas três instâncias PostgreSQL no Amazon RDS, separadas para autenticação, flags e regras de targeting. As instâncias ficaram restritas à rede privada.

![Três bancos PostgreSQL no RDS](evidencias/prints/08-rds-bancos.png)

O Redis no Amazon ElastiCache foi utilizado como cache pelo serviço de avaliação.

![Redis no Amazon ElastiCache](evidencias/prints/09-elasticache-redis.png)

A tabela `ToggleMasterAnalytics` foi criada no DynamoDB para armazenar os eventos das avaliações. Ela utiliza capacidade sob demanda e recuperação em um ponto anterior no tempo.

![Tabela de analytics no DynamoDB](evidencias/prints/10-dynamodb-tabela.png)

A fila `togglemaster-events` recebe os eventos produzidos pelo serviço de avaliação. A fila `togglemaster-events-dlq` preserva mensagens que não puderem ser processadas após as tentativas definidas.

![Fila SQS e DLQ](evidencias/prints/11-sqs-filas.png)

## Imagens e gerenciamento de segredos

Cada microsserviço possui um repositório privado no Amazon ECR. As imagens são publicadas com a tag correspondente ao SHA do commit, sem uso de `latest` nos deployments.

![Cinco repositórios no ECR](evidencias/prints/12-ecr-repositorios.png)

![Imagem identificada pelo SHA do commit](evidencias/prints/13-ecr-imagem-sha.png)

As senhas dos bancos e as chaves internas da aplicação foram armazenadas no AWS Secrets Manager. O External Secrets Operator entrega esses dados ao Kubernetes sem incluir valores sensíveis nos manifests versionados.

![Secrets do ToggleMaster no AWS Secrets Manager](evidencias/prints/14-secrets-manager.png)

## Pipelines DevSecOps

Os cinco microsserviços possuem pipelines próprios no GitHub Actions e compartilham um workflow reutilizável. As execuções contemplam testes unitários, lint, SAST, análise de dependências, build da imagem e scan do container.

![Pipeline aprovado do auth-service](evidencias/prints/15-pipelines-sucesso-auth.png)

![Pipeline aprovado do flag-service](evidencias/prints/15-pipelines-sucesso-flag.png)

![Pipeline aprovado do targeting-service](evidencias/prints/15-pipelines-sucesso-targeting.png)

![Pipeline aprovado do evaluation-service](evidencias/prints/15-pipelines-sucesso-evaluation.png)

![Pipeline aprovado do analytics-service](evidencias/prints/15-pipelines-sucesso-analytics.png)

### Bloqueio por vulnerabilidade crítica

Uma Pull Request temporária foi utilizada para demonstrar a política de bloqueio. O Trivy encontrou três vulnerabilidades críticas corrigíveis e interrompeu o pipeline durante o scan da imagem. Como a falha ocorreu antes da publicação, a imagem vulnerável não foi enviada ao ECR e a alteração não foi integrada à branch `main`.

![Pipeline bloqueado pelo Trivy](evidencias/prints/16-pipeline-bloqueado.png)

[Execução bloqueada no GitHub Actions](https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916194667)

### Execução após a correção

Depois da atualização segura da imagem-base, uma nova execução concluiu testes, análises e scan sem vulnerabilidades críticas corrigíveis.

![Pipeline aprovado depois da correção](evidencias/prints/17-pipeline-corrigido.png)

[Execução aprovada no GitHub Actions](https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916382484)

## Entrega por GitOps

Após a aprovação do pipeline, a imagem foi publicada no ECR com o SHA do commit. O workflow atualizou o arquivo Kustomize correspondente e criou um commit automático como `github-actions[bot]`.

![Commit automático do GitOps](evidencias/prints/18-gitops-commit.png)

O manifesto passou a apontar para o repositório ECR e para a tag imutável gerada no pipeline.

![Tag SHA registrada no Kustomize](evidencias/prints/19-gitops-tag-sha.png)

## ArgoCD e Kubernetes

O ArgoCD monitorou a pasta GitOps e sincronizou a aplicação raiz e os cinco microsserviços. As aplicações foram registradas como `Synced` e `Healthy`, confirmando a correspondência entre o Git e o cluster.

![Aplicações sincronizadas no ArgoCD](evidencias/prints/20-argocd-aplicacoes-01.png)

![Recursos das aplicações no ArgoCD](evidencias/prints/20-argocd-aplicacoes-02.png)

Os cinco deployments permaneceram disponíveis no EKS. O `evaluation-service` utiliza duas réplicas, resultando em seis pods das aplicações em execução.

![Pods das aplicações no Amazon EKS](evidencias/prints/21-kubernetes-pods.png)

## Teste E2E no ambiente AWS

O teste integrado executado na AWS validou a sessão, os nodes, os deployments, os pods e os cinco health checks. Em seguida, configurou uma feature flag, aplicou uma regra de liberação para 100% dos usuários e realizou uma avaliação com resultado positivo.

O `evaluation-service` publicou o evento no SQS. O `analytics-service` consumiu a mensagem e gravou o registro correspondente no DynamoDB. A execução terminou com a mensagem `Teste E2E AWS: APROVADO`.

![E2E AWS — ambiente validado](evidencias/prints/22-e2e-aws-01.png)

![E2E AWS — health checks](evidencias/prints/22-e2e-aws-02.png)

![E2E AWS — flag e targeting](evidencias/prints/22-e2e-aws-03.png)

![E2E AWS — SQS e analytics](evidencias/prints/22-e2e-aws-04.png)

![E2E AWS — resultado aprovado](evidencias/prints/22-e2e-aws-05.png)

O log detalhado está registrado em [e2e-aws-detalhado.txt](evidencias/e2e-aws-detalhado.txt).

## Evento armazenado no DynamoDB

O item final no DynamoDB relaciona o identificador do evento, o usuário avaliado, a flag, o resultado e o horário. Esse registro confirma o percurso completo entre avaliação, SQS, analytics e armazenamento.

![Evento final armazenado no DynamoDB](evidencias/prints/23-dynamodb-evento.png)

## Estimativa de custos

A arquitetura foi cadastrada no AWS Pricing Calculator para a região `us-east-1`. A estimativa exportada apresenta custo inicial de **US$ 180,00**, custo mensal de **US$ 397,90** e total previsto de **US$ 4.954,80** para 12 meses.

![Resumo da estimativa no AWS Pricing Calculator](evidencias/prints/24-pricing-calculator.png)

Os artefatos completos estão disponíveis em:

- [estimativa em PDF](<ToggleMaster - Homologacao.pdf>);
- [estimativa detalhada em JSON](<evidencias/ToggleMaster - Ambiente de Homologação AWS.json>);
- [estimativa compartilhada no AWS Pricing Calculator](https://calculator.aws/#/estimate?id=e5aa62adc88442cfef1fd080f53da37a9416e875).

## Registros textuais

Além das comprovações visuais, foram mantidos os seguintes registros de execução:

- [infraestrutura validada](evidencias/infraestrutura-validada.txt);
- [pipeline de segurança](evidencias/pipeline-seguranca.txt);
- [GitOps e E2E](evidencias/gitops-e2e.txt);
- [E2E AWS detalhado](evidencias/e2e-aws-detalhado.txt).

## Conclusão

As evidências registradas demonstram que o ToggleMaster foi entregue com infraestrutura reproduzível, validações de segurança, imagens rastreáveis, segredos externos ao código e deploy controlado por GitOps. O fluxo completo foi validado localmente e na AWS, incluindo a comunicação entre os cinco microsserviços e a persistência final dos eventos de avaliação.
