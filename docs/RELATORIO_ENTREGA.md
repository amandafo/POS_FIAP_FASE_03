# Relatório de Entrega — Tech Challenge Fase 3

## Participantes

- Preencher nome completo e RM antes da entrega.

## Links

- Repositório: https://github.com/amandafo/POS_FIAP_FASE_03
- Vídeo: preencher depois da gravação.
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

## Evidências que ainda devem ser adicionadas

- Terraform plan/apply e recursos ativos na AWS.
- Pipeline bloqueado por vulnerabilidade e pipeline aprovado após correção.
- Imagens com SHA no ECR.
- Commit automático alterando GitOps.
- Cinco aplicações `Synced` e `Healthy` no ArgoCD.
- Pods do ToggleMaster em execução e teste E2E na AWS.
- Estimativa da AWS Pricing Calculator.

## Estimativa de custos

Adicionar aqui o resumo e a captura da AWS Pricing Calculator antes da entrega. Considerar EKS, nodes EC2, três RDS, Redis, NAT Gateway, Load Balancer, S3, ECR, SQS e DynamoDB.

## Encerramento do laboratório

Após gravar o vídeo e salvar as evidências, executar `terraform destroy` para evitar consumo da cota. O bucket do state deve ser removido somente depois da destruição completa dos recursos.
