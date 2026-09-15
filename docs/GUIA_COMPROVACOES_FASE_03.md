# Guia de comprovações — Tech Challenge Fase 3

Este documento mostra tudo o que foi implementado no ToggleMaster e explica como obter as evidências para a entrega. Ele foi escrito para orientar a gravação do vídeo e a criação do relatório final.

O projeto usa a **Opção A — AWS Academy** e a região **N. Virginia (`us-east-1`)**.

> Antes de tirar qualquer print, feche a tela `AWS Details` do Academy e qualquer arquivo ou terminal que mostre credenciais. Não abra o valor dos secrets. Recorte ou esconda o ID da conta, nome do usuário, e-mail, endpoints privados e qualquer token que aparecer.

## 1. O que foi realizado

O ToggleMaster foi transformado em uma plataforma de microsserviços automatizada. O trabalho realizado inclui:

- cinco microsserviços: autenticação, flags, segmentação, avaliação e analytics;
- execução local completa com Docker Compose;
- testes unitários, lint, SAST, SCA e scan das imagens;
- infraestrutura AWS criada com Terraform modular;
- state remoto do Terraform armazenado no S3;
- VPC com duas subnets públicas e duas privadas;
- Internet Gateway, NAT Gateway e tabelas de rotas;
- cluster EKS com Managed Node Group e dois nodes;
- uso da `LabRole` existente, sem criação de roles ou policies IAM;
- três bancos PostgreSQL no RDS;
- um Redis no ElastiCache;
- uma tabela no DynamoDB;
- uma fila SQS e uma fila de erro (DLQ);
- cinco repositórios de imagens no ECR;
- segredos armazenados no AWS Secrets Manager;
- ArgoCD, External Secrets Operator e Metrics Server instalados;
- cinco pipelines no GitHub Actions;
- publicação das imagens no ECR com a tag igual ao SHA do commit;
- atualização automática dos arquivos GitOps;
- sincronização automática das aplicações pelo ArgoCD;
- teste E2E local e teste E2E no ambiente AWS;
- demonstração de pipeline bloqueado por vulnerabilidades críticas e aprovado depois da correção.

## 2. Resultado já validado

As seguintes validações já foram concluídas:

- Terraform: 50 recursos de infraestrutura criados e 3 charts Helm instalados;
- EKS: cluster e node group em estado `ACTIVE`;
- Kubernetes: dois nodes `Ready`;
- RDS: três bancos em estado `Available`;
- DynamoDB: tabela `ToggleMasterAnalytics` ativa;
- SQS: fila `togglemaster-events` e DLQ criadas;
- ECR: cinco repositórios com imagens identificadas pelo SHA;
- GitHub Actions: cinco pipelines aprovados;
- ArgoCD: aplicação raiz e cinco aplicações `Synced` e `Healthy`;
- aplicações: seis réplicas em estado `Running`, sem reinícios na validação;
- E2E AWS: avaliação positiva, evento consumido da fila e salvo no DynamoDB;
- segurança: três vulnerabilidades críticas bloquearam uma execução de demonstração;
- correção: o pipeline passou depois da atualização segura da imagem.

## 3. Organização dos prints

Crie a pasta abaixo, caso ainda não exista:

```bash
mkdir -p docs/evidencias/prints
```

Use estes nomes para deixar as evidências na ordem correta:

| Arquivo | Comprovação |
|---|---|
| `01-repositorio-estrutura.png` | Código, Terraform, workflows e GitOps |
| `02-teste-local-e2e.png` | Fluxo completo executado localmente |
| `03-terraform-plan.png` | Infraestrutura controlada por Terraform |
| `04-s3-state-remoto.png` | State remoto protegido no S3 |
| `05-vpc-resource-map.png` | VPC, subnets, rotas, IGW e NAT |
| `06-eks-cluster.png` | Cluster EKS ativo |
| `07-eks-nodes.png` | Managed Node Group e dois nodes |
| `08-rds-bancos.png` | Três bancos PostgreSQL |
| `09-elasticache-redis.png` | Redis disponível |
| `10-dynamodb-tabela.png` | Tabela de analytics ativa |
| `11-sqs-filas.png` | Fila de eventos e DLQ |
| `12-ecr-repositorios.png` | Cinco repositórios ECR |
| `13-ecr-imagem-sha.png` | Imagem publicada com SHA do commit |
| `14-secrets-manager.png` | Secrets armazenados com segurança |
| `15-pipelines-sucesso.png` | Pipelines dos cinco serviços aprovados |
| `16-pipeline-bloqueado.png` | Trivy bloqueando vulnerabilidades críticas |
| `17-pipeline-corrigido.png` | Pipeline aprovado depois da correção |
| `18-gitops-commit.png` | Commit automático feito pelo pipeline |
| `19-gitops-tag-sha.png` | Tag alterada no arquivo do GitOps |
| `20-argocd-aplicacoes.png` | Aplicações sincronizadas e saudáveis |
| `21-kubernetes-pods.png` | Pods dos microsserviços em execução |
| `22-e2e-aws.png` | Teste funcional completo na AWS |
| `23-dynamodb-evento.png` | Evento final gravado no DynamoDB |
| `24-pricing-calculator.png` | Estimativa mensal da arquitetura |

Não é obrigatório usar todos os 24 prints no relatório. Eles formam um acervo completo; no vídeo e no PDF podem ser selecionados os mais importantes.

## 4. Comprovação do código no GitHub

### Print 01 — estrutura do repositório

**O que comprova:** que o código dos serviços, o Terraform, os pipelines e o GitOps foram entregues no repositório.

**Caminho para chegar à tela:**

1. Acesse `https://github.com/amandafo/POS_FIAP_FASE_03`.
2. Clique na aba **Code**.
3. Deixe visíveis as pastas `.github`, `infra`, `gitops` e as pastas dos cinco serviços.

**O que precisa aparecer no print:** nome do repositório e a lista das principais pastas.

**Salvar como:** `docs/evidencias/prints/01-repositorio-estrutura.png`.

Para mostrar a modularização do Terraform durante o vídeo:

1. Na aba **Code**, clique em `infra`.
2. Clique em `modules`.
3. Mostre as pastas `network`, `eks`, `databases`, `messaging`, `ecr` e `platform`.

Para mostrar os workflows:

1. Volte à raiz do repositório.
2. Clique em `.github`.
3. Clique em `workflows`.
4. Mostre os cinco workflows e o arquivo `reusable-service-ci.yml`.

## 5. Comprovação local

### Print 02 — teste E2E local

**O que comprova:** que os cinco serviços trabalham em conjunto antes do deploy na AWS.

Execute:

```bash
cd ~/Repositories/pos_amanda/repo/fase_03
make local-up
make health
make e2e
```

No final devem aparecer:

- os cinco health checks com `status: ok`;
- validação da chave de API;
- criação da flag;
- criação da regra;
- resposta da avaliação com `result: true`;
- evento salvo no DynamoDB Local;
- mensagem `Comprovacao concluida`.

Tire o print da parte final do comando, mostrando o evento no DynamoDB e a mensagem de conclusão.

**Salvar como:** `docs/evidencias/prints/02-teste-local-e2e.png`.

Para mostrar os testes automatizados:

```bash
make test
```

Para desligar o ambiente depois da apresentação local:

```bash
make local-down
```

## 6. Comprovação do Terraform

### Print 03 — Terraform plan

**O que comprova:** que a infraestrutura está descrita como código e que o ambiente aplicado corresponde aos arquivos Terraform.

Com uma sessão válida do AWS Academy, execute fora da gravação:

```bash
cd ~/Repositories/pos_amanda/repo/fase_03
source scripts/aws-academy-env.sh
aws sts get-caller-identity
```

Limpe o terminal antes do print e execute:

```bash
./scripts/terraform-docker.sh plan
```

Se o ambiente não foi alterado, o resultado esperado é semelhante a:

```text
No changes. Your infrastructure matches the configuration.
```

Se houver alterações inesperadas, não aplique antes de revisar.

**O que precisa aparecer no print:** o comando e o resumo final do plano. Não mostre credenciais, endpoints ou ARNs completos.

**Salvar como:** `docs/evidencias/prints/03-terraform-plan.png`.

Durante a explicação, mostre também estes arquivos no GitHub:

- `infra/backend.tf`: configura o state remoto no S3;
- `infra/main.tf`: chama os módulos;
- `infra/modules/network`: cria a rede;
- `infra/modules/eks`: cria EKS e node group usando a `LabRole`;
- `infra/modules/databases`: cria RDS, Redis e secrets;
- `infra/modules/messaging`: cria SQS, DLQ e DynamoDB;
- `infra/modules/ecr`: cria os cinco repositórios;
- `infra/modules/platform`: instala ArgoCD, External Secrets e Metrics Server.

## 7. Comprovações no Console AWS

Antes de cada print:

1. Confira no canto superior direito se a região é **N. Virginia (`us-east-1`)**.
2. Feche o painel do AWS Academy que mostra credenciais.
3. Evite mostrar o menu da conta no canto superior direito.

### Print 04 — state remoto no S3

**O que comprova:** que o arquivo `terraform.tfstate` não fica somente na máquina local.

**Caminho para chegar à tela:**

1. No Console AWS, clique na barra de pesquisa superior.
2. Pesquise por **S3** e abra o serviço.
3. No menu esquerdo, clique em **General purpose buckets** ou **Buckets de uso geral**.
4. Localize o bucket cujo nome começa com `togglemaster-tfstate-`.
5. Abra o bucket.
6. Na aba **Objects**, abra a pasta `fase-03` e depois `homolog`.
7. Confirme que existe o objeto `terraform.tfstate`.

Para comprovar as proteções:

1. Volte à página do bucket.
2. Clique na aba **Properties**.
3. Mostre **Bucket Versioning: Enabled** e **Default encryption: Enabled**.
4. Na aba **Permissions**, mostre que **Block public access** está ativado.

Não abra nem baixe o conteúdo do `terraform.tfstate`.

**Salvar como:** `docs/evidencias/prints/04-s3-state-remoto.png`.

### Print 05 — mapa da VPC

**O que comprova:** VPC, duas subnets públicas, duas privadas, tabelas de rotas, Internet Gateway e NAT Gateway.

**Caminho para chegar à tela:**

1. Pesquise por **VPC** na barra superior do Console AWS.
2. Abra o serviço **VPC**.
3. No menu esquerdo, clique em **Your VPCs** ou **Suas VPCs**.
4. Selecione `togglemaster-homolog-vpc`.
5. Abra a aba **Resource map** ou **Mapa de recursos**.
6. Clique em **Show details**, se a opção estiver disponível.

**O que precisa aparecer:** uma VPC, quatro subnets, as tabelas de rotas, o Internet Gateway e o NAT Gateway. As duas zonas devem ser `us-east-1a` e `us-east-1b`.

**Salvar como:** `docs/evidencias/prints/05-vpc-resource-map.png`.

### Print 06 — cluster EKS

**O que comprova:** que o cluster Kubernetes foi criado e está ativo.

**Caminho para chegar à tela:**

1. Pesquise por **EKS**.
2. Abra **Elastic Kubernetes Service**.
3. No menu esquerdo, clique em **Clusters**.
4. Clique em `togglemaster-cluster`.
5. Abra a aba **Overview** ou permaneça na página principal do cluster.

**O que precisa aparecer:** nome `togglemaster-cluster` e status `Active`.

**Salvar como:** `docs/evidencias/prints/06-eks-cluster.png`.

### Print 07 — node group e nodes

**O que comprova:** que o EKS possui capacidade de processamento usando Managed Node Group.

**Caminho para chegar à tela:**

1. Dentro do cluster `togglemaster-cluster`, clique na aba **Compute**.
2. Em **Node groups**, clique em `togglemaster-cluster-nodes`.
3. Mostre o status `Active` e a configuração desejada de dois nodes.
4. Volte à aba **Compute** para mostrar a lista de nodes, se disponível.

**O que precisa aparecer:** node group ativo e dois nodes.

**Salvar como:** `docs/evidencias/prints/07-eks-nodes.png`.

### Print 08 — bancos RDS

**O que comprova:** os três bancos PostgreSQL pedidos no enunciado.

**Caminho para chegar à tela:**

1. Pesquise por **RDS**.
2. Abra **RDS**.
3. No menu esquerdo, clique em **Databases** ou **Bancos de dados**.
4. Na busca, filtre por `togglemaster-homolog`.

**O que precisa aparecer:**

- `togglemaster-homolog-auth`;
- `togglemaster-homolog-flag`;
- `togglemaster-homolog-targeting`;
- engine PostgreSQL;
- status `Available`.

Não abra a seção de credenciais ou endpoints.

**Salvar como:** `docs/evidencias/prints/08-rds-bancos.png`.

### Print 09 — Redis no ElastiCache

**O que comprova:** o cache usado para acelerar a avaliação das flags.

**Caminho para chegar à tela:**

1. Pesquise por **ElastiCache**.
2. Abra **ElastiCache**.
3. No painel do serviço, clique em **Redis OSS caches**, **Redis OSS** ou **Caches**, conforme o menu exibido.
4. Localize `togglemaster-homolog-redis`.
5. Se necessário, abra o recurso para mostrar os detalhes.

**O que precisa aparecer:** nome, engine Redis, um node e status disponível.

Evite mostrar o endpoint completo.

**Salvar como:** `docs/evidencias/prints/09-elasticache-redis.png`.

### Print 10 — tabela DynamoDB

**O que comprova:** o armazenamento dos eventos de avaliação.

**Caminho para chegar à tela:**

1. Pesquise por **DynamoDB**.
2. Abra **DynamoDB**.
3. No menu esquerdo, clique em **Tables** ou **Tabelas**.
4. Clique em `ToggleMasterAnalytics`.
5. Abra a aba **Overview**.

**O que precisa aparecer:** nome da tabela, status `Active`, chave de partição `event_id`, modo `On-demand` e criptografia habilitada.

**Salvar como:** `docs/evidencias/prints/10-dynamodb-tabela.png`.

### Print 11 — SQS e DLQ

**O que comprova:** a comunicação assíncrona entre avaliação e analytics, incluindo a fila de erro.

**Caminho para chegar à tela:**

1. Pesquise por **SQS**.
2. Abra **Simple Queue Service**.
3. No menu esquerdo, clique em **Queues** ou **Filas**.
4. Na busca, digite `togglemaster-events`.

**O que precisa aparecer:**

- `togglemaster-events`;
- `togglemaster-events-dlq`.

Se quiser mostrar a ligação com a DLQ:

1. Clique em `togglemaster-events`.
2. Abra a seção **Dead-letter queue** ou **Fila de mensagens mortas**.
3. Mostre que a DLQ está configurada, sem expor a URL completa da fila.

**Salvar como:** `docs/evidencias/prints/11-sqs-filas.png`.

### Print 12 — cinco repositórios ECR

**O que comprova:** que cada microsserviço possui seu próprio repositório de imagens.

**Caminho para chegar à tela:**

1. Pesquise por **ECR**.
2. Abra **Elastic Container Registry**.
3. No menu esquerdo, clique em **Private registry** e depois em **Repositories**, ou diretamente em **Repositories**.

**O que precisa aparecer:**

- `auth-service`;
- `flag-service`;
- `targeting-service`;
- `evaluation-service`;
- `analytics-service`.

**Salvar como:** `docs/evidencias/prints/12-ecr-repositorios.png`.

### Print 13 — imagem com SHA no ECR

**O que comprova:** que o pipeline não usa `latest`; cada imagem identifica exatamente o código que a criou.

**Caminho para chegar à tela:**

1. Na lista dos repositórios ECR, clique em `evaluation-service`.
2. Abra a lista de imagens.
3. Localize a imagem cuja tag começa com `7edbee1`.

**O que precisa aparecer:** a tag completa baseada no SHA, data de publicação e scan sem vulnerabilidade crítica.

O URI contém o ID da conta. Para uma entrega pública, recorte ou oculte essa parte mantendo visível o nome do repositório e a tag.

**Salvar como:** `docs/evidencias/prints/13-ecr-imagem-sha.png`.

### Print 14 — Secrets Manager

**O que comprova:** que senhas e chaves não estão salvas nos arquivos Kubernetes.

**Caminho para chegar à tela:**

1. Pesquise por **Secrets Manager**.
2. Abra **AWS Secrets Manager**.
3. No menu esquerdo, clique em **Secrets**.
4. Na busca, filtre por `togglemaster/homolog`.

**O que precisa aparecer:** somente a lista de nomes, como os secrets de `auth-db`, `flag-db`, `targeting-db`, `application` e `runtime`.

> Não clique em **Retrieve secret value** e não mostre os valores dos secrets.

**Salvar como:** `docs/evidencias/prints/14-secrets-manager.png`.

## 8. Comprovações do pipeline DevSecOps

### Print 15 — cinco pipelines aprovados

**O que comprova:** que cada microsserviço possui CI próprio.

**Caminho para chegar à tela:**

1. Acesse `https://github.com/amandafo/POS_FIAP_FASE_03`.
2. Clique na aba **Actions**.
3. Observe a lista de workflows na lateral esquerda.
4. Abra cada workflow ou mostre a lista de execuções do commit `7edbee1`.

**O que precisa aparecer:** `auth-service`, `flag-service`, `targeting-service`, `evaluation-service` e `analytics-service` com status verde de sucesso.

**Salvar como:** `docs/evidencias/prints/15-pipelines-sucesso.png`.

Cada pipeline contém:

1. testes unitários;
2. lint;
3. SAST com Gosec ou Bandit;
4. SCA com Trivy;
5. build da imagem;
6. scan da imagem com Trivy;
7. login no ECR;
8. publicação usando o SHA;
9. atualização automática do GitOps.

### Print 16 — pipeline bloqueado

**O que comprova:** que vulnerabilidades críticas impedem a continuidade do pipeline.

**Caminho direto:**

`https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916194667`

**Caminho pelos menus:**

1. Repositório no GitHub.
2. Aba **Actions**.
3. Abra a execução que falhou na demonstração de segurança.
4. Clique no job `devsecops` ou `pipeline`.
5. Expanda o passo vermelho **Scan da imagem**.

**O que precisa aparecer:** status de falha, passo `Scan da imagem` e as três vulnerabilidades `CRITICAL` encontradas pelo Trivy.

Se alguma linha mostrar informação que não deve ser publicada, recorte o print para manter apenas o nome do pacote, a severidade e o resultado da execução.

**Salvar como:** `docs/evidencias/prints/16-pipeline-bloqueado.png`.

Essa alteração foi feita apenas em uma Pull Request de demonstração, fechada sem merge. Portanto, a versão vulnerável não entrou na `main` e não foi publicada no ECR.

### Print 17 — pipeline corrigido

**O que comprova:** que a correção removeu o bloqueio e todas as verificações foram aprovadas.

**Caminho direto:**

`https://github.com/amandafo/POS_FIAP_FASE_03/actions/runs/34916382484`

**Caminho pelos menus:**

1. Repositório no GitHub.
2. Aba **Actions**.
3. Abra a execução aprovada depois da correção.
4. Clique no job principal para mostrar os passos.

**O que precisa aparecer:** execução verde e testes, lint, SAST, SCA, build e scan aprovados.

**Salvar como:** `docs/evidencias/prints/17-pipeline-corrigido.png`.

## 9. Comprovações de GitOps

### Print 18 — commit automático

**O que comprova:** que o pipeline altera o repositório GitOps, em vez de executar `kubectl apply` diretamente.

**Caminho para chegar à tela:**

1. Abra o repositório no GitHub.
2. Na aba **Code**, clique no link de **commits** acima da lista de arquivos.
3. Procure os commits com a mensagem `chore(gitops): atualiza ...`.
4. Abra um desses commits.

**O que precisa aparecer:** autor `github-actions[bot]`, mensagem do commit e alteração no arquivo `gitops/apps/<serviço>/kustomization.yaml`.

**Salvar como:** `docs/evidencias/prints/18-gitops-commit.png`.

### Print 19 — tag da imagem no GitOps

**O que comprova:** que o GitOps aponta para uma versão imutável da imagem.

**Caminho para chegar à tela:**

1. Aba **Code** do repositório.
2. Clique em `gitops`.
3. Clique em `apps`.
4. Clique em `evaluation-service`.
5. Abra `kustomization.yaml`.

**O que precisa aparecer:** `newName` apontando para o ECR e `newTag` com o SHA completo do commit, sem uso de `latest`.

Para uma entrega pública, oculte somente o ID da conta existente antes de `.dkr.ecr`, sem esconder o nome do serviço ou a tag.

**Salvar como:** `docs/evidencias/prints/19-gitops-tag-sha.png`.

## 10. Comprovações do ArgoCD e Kubernetes

Primeiro carregue uma sessão válida do Academy e conecte o `kubectl` ao cluster:

```bash
cd ~/Repositories/pos_amanda/repo/fase_03
source scripts/aws-academy-env.sh
aws eks update-kubeconfig --region us-east-1 --name togglemaster-cluster
kubectl get nodes
```

### Print 20 — ArgoCD sincronizado

**O que comprova:** que o ArgoCD detectou os commits GitOps e implantou os serviços automaticamente.

Abra o ArgoCD:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Em outro terminal, consulte a senha inicial:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 --decode
printf '\n'
```

Não grave nem tire print do terminal que mostrar essa senha. Depois:

1. Acesse `http://localhost:8080`.
2. Entre com o usuário `admin` e a senha consultada.
3. Abra a página **Applications**.

**O que precisa aparecer:**

- aplicação raiz `togglemaster`;
- `auth-service`;
- `flag-service`;
- `targeting-service`;
- `evaluation-service`;
- `analytics-service`;
- estados `Synced` e `Healthy`.

**Salvar como:** `docs/evidencias/prints/20-argocd-aplicacoes.png`.

Se o ArgoCD não abrir, confirme:

```bash
kubectl get pods -n argocd
kubectl get applications -n argocd
```

### Print 21 — pods das aplicações

**O que comprova:** que a versão sincronizada pelo ArgoCD está realmente em execução no EKS.

Execute:

```bash
kubectl get nodes
kubectl get applications -n argocd
kubectl get pods -n togglemaster -o wide
kubectl get services -n togglemaster
```

**O que precisa aparecer:** dois nodes `Ready`, aplicações sincronizadas e os pods dos cinco serviços em estado `Running`. O `evaluation-service` possui duas réplicas, por isso o total esperado é de seis pods das aplicações.

**Salvar como:** `docs/evidencias/prints/21-kubernetes-pods.png`.

Para comprovar os componentes da plataforma:

```bash
kubectl get pods -n argocd
kubectl get pods -n external-secrets
kubectl get pods -n kube-system | grep metrics-server
kubectl get externalsecrets -n togglemaster
```

Para comprovar os bancos inicializados:

```bash
kubectl get jobs -n togglemaster
```

Os três jobs de inicialização devem aparecer como concluídos.

### Print 22 — teste E2E na AWS

**O que comprova:** o funcionamento completo da aplicação implantada na nuvem.

Com as credenciais temporárias carregadas e o `kubectl` conectado, execute:

```bash
./scripts/comprovacao-aws-e2e.sh
```

**O que precisa aparecer:**

```text
Health checks: cinco servicos aprovados.
Flag e regra de targeting: configuradas.
Evaluation service: decisao positiva aprovada.
SQS e analytics: evento consumido e gravado no DynamoDB.
Teste E2E AWS: APROVADO.
```

O script usa a chave da aplicação internamente, mas não imprime o valor.

**Salvar como:** `docs/evidencias/prints/22-e2e-aws.png`.

### Print 23 — evento no DynamoDB

**O que comprova:** que a avaliação passou pelo SQS, foi consumida pelo analytics e chegou ao armazenamento final.

Tire este print logo depois do teste E2E AWS:

1. Console AWS.
2. Pesquise por **DynamoDB**.
3. Clique em **Tables**.
4. Abra `ToggleMasterAnalytics`.
5. Clique em **Explore table items** ou **Explorar itens da tabela**.
6. Atualize a lista de itens.
7. Abra o item mais recente, se necessário.

**O que precisa aparecer:** um evento relacionado à flag `enable-new-dashboard` e ao usuário de teste, sem dados sensíveis.

**Salvar como:** `docs/evidencias/prints/23-dynamodb-evento.png`.

## 11. Estimativa de custos

### Print 24 — AWS Pricing Calculator

**O que comprova:** o custo mensal estimado da arquitetura exigida pelo desafio. A estimativa não é a fatura do AWS Academy.

**Caminho para chegar à tela:**

1. Acesse `https://calculator.aws/#/`.
2. Clique em **Create estimate**.
3. Crie um grupo chamado `ToggleMaster - Homologacao`.
4. Clique em **Add service**.
5. Pesquise cada serviço, clique em **Configure**, preencha os valores e depois em **Save and add service**.
6. Ao terminar, clique em **View summary**.

Use a região **US East (N. Virginia)** e considere um mês com aproximadamente 730 horas.

Adicione os seguintes itens:

| Serviço na calculadora | Configuração usada no projeto |
|---|---|
| Amazon EKS | 1 cluster, 730 horas/mês |
| Amazon EC2 | 2 instâncias Linux `t3.medium`, On-Demand, 730 horas/mês |
| Amazon EBS | aproximadamente 20 GB `gp3` para cada node |
| Amazon RDS for PostgreSQL | 3 instâncias `db.t3.micro`, Single-AZ, 20 GB `gp3` cada |
| Amazon ElastiCache | 1 node Redis `cache.t3.micro`, sem réplica |
| NAT Gateway | 1 gateway, 730 horas e baixo volume de dados para homologação |
| Elastic Load Balancing | 1 Network Load Balancer, 730 horas e baixo volume de dados |
| Amazon S3 | pequeno armazenamento para o state e versionamento |
| Amazon ECR | 5 repositórios, usando uma estimativa pequena de armazenamento |
| Amazon SQS | baixo volume de requisições de homologação |
| Amazon DynamoDB | modo On-Demand, baixo volume de leitura e escrita |
| AWS Secrets Manager | 5 secrets e baixo número de chamadas |

O Console pode agrupar EBS dentro da configuração do EC2. Serviços com uso muito baixo podem apresentar custo próximo de zero, mas devem permanecer descritos na estimativa.

**O que precisa aparecer no print:** nome da estimativa, lista dos principais serviços e total mensal estimado.

**Salvar como:** `docs/evidencias/prints/24-pricing-calculator.png`.

Depois, use a opção **Export** para salvar a estimativa em PDF ou CSV, se estiver disponível. Guarde também o link compartilhável da estimativa para incluir no relatório.

## 12. Evidências textuais já existentes

Além dos prints, o projeto já possui registros sem credenciais:

- `docs/evidencias/infraestrutura-validada.txt`;
- `docs/evidencias/pipeline-seguranca.txt`;
- `docs/evidencias/gitops-e2e.txt`.

Esses arquivos registram o resultado final da infraestrutura, a demonstração de segurança e o teste GitOps/E2E.

## 13. Ordem sugerida para mostrar no vídeo

O vídeo deve ter até 20 minutos. Uma sequência simples é:

1. apresentar o problema e os cinco microsserviços;
2. mostrar a estrutura do repositório;
3. mostrar os módulos Terraform e o `terraform plan`;
4. mostrar rapidamente a VPC, EKS, RDS, Redis, SQS, DynamoDB, ECR e Secrets Manager;
5. abrir o pipeline que falhou por vulnerabilidade crítica;
6. abrir o pipeline aprovado depois da correção;
7. mostrar o commit automático e a nova tag na pasta GitOps;
8. mostrar as cinco aplicações no ArgoCD como `Synced` e `Healthy`;
9. mostrar os pods no EKS;
10. executar ou mostrar o resultado do teste E2E AWS;
11. mostrar o evento no DynamoDB;
12. finalizar com a estimativa de custos.

## 14. Checklist antes de entregar

- [ ] Todos os prints foram revisados e não mostram credenciais.
- [ ] Participantes e RMs foram preenchidos no relatório.
- [ ] Link do repositório foi conferido.
- [ ] Vídeo tem no máximo 20 minutos.
- [ ] Link público ou compartilhável do vídeo foi testado em janela anônima.
- [ ] Estimativa de custos foi adicionada ao relatório.
- [ ] Resumo das decisões e dificuldades foi revisado.
- [ ] Relatório final foi exportado em PDF ou TXT.
- [ ] Arquivos de credenciais continuam ignorados pelo Git.
- [ ] Recursos AWS somente serão destruídos depois da gravação e da coleta das evidências.

## 15. Encerramento do ambiente

Não destrua os recursos antes de concluir todos os prints e o vídeo. Depois que as evidências estiverem salvas e revisadas, carregue uma sessão válida do Academy e faça:

```bash
cd ~/Repositories/pos_amanda/repo/fase_03
source scripts/aws-academy-env.sh
./scripts/terraform-docker.sh plan -destroy
./scripts/terraform-docker.sh destroy
```

Revise cuidadosamente o plano de destruição antes de confirmar. O bucket do state deve ser removido somente depois que o Terraform terminar de destruir os demais recursos.
