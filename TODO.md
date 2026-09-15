# TODO — Tech Challenge Fase 3

Este arquivo registra o que já foi feito e o que ainda falta. Atualizar as caixas sempre que uma etapa for concluída.

## Preparação local

- [x] Ler o enunciado da Fase 3.
- [x] Definir a Opção A: AWS Academy.
- [x] Criar o guia privado com o passo a passo completo.
- [x] Criar `.gitignore` para Terraform, secrets, caches e guia privado.
- [x] Copiar os cinco microsserviços da Fase 2 sem a pasta `.git`.
- [x] Não copiar `k8s/secrets.yaml`, credenciais, imagens, ZIPs ou PDFs antigos.
- [x] Remover da Fase 3 os relatórios antigos copiados da Fase 2.
- [x] Inicializar o Git na `fase_03` com branch `main`.
- [x] Configurar `origin` como `https://github.com/amandafo/POS_FIAP_FASE_03.git`.
- [x] Construir todas as imagens localmente com Docker Compose.
- [x] Validar os cinco endpoints `/health`.
- [x] Executar o fluxo E2E local completo.
- [x] Confirmar autenticação, flag, targeting, evaluation, fila e DynamoDB local.
- [x] Criar testes unitários iniciais para os cinco microsserviços.
- [x] Criar comandos únicos para testes, lint, SAST, SCA e Terraform local.
- [x] Criar o esqueleto modular do Terraform.
- [x] Criar README inicial da Fase 3.
- [x] Executar e aprovar todos os testes unitários.
- [x] Executar e aprovar lint e SAST local.
- [x] Executar SCA com Trivy e tratar vulnerabilidades críticas.
- [x] Validar o esqueleto Terraform com `fmt` e `validate`.
- [x] Revisar se não existem credenciais ou endpoints antigos.
- [x] Fazer o primeiro commit local com a base segura.
- [x] Publicar o primeiro commit no GitHub.

## AWS Academy

- [x] Iniciar nova sessão do laboratório.
- [x] Renovar credenciais temporárias locais.
- [x] Validar conta e `LabRole`.
- [x] Criar bucket S3 criptografado para o state remoto.
- [x] Conectar o Terraform ao backend remoto com lock.
- [x] Implementar e aplicar módulo de rede.
- [x] Implementar e aplicar cinco repositórios ECR.
- [x] Implementar e aplicar SQS, DLQ e DynamoDB.
- [x] Implementar e aplicar três RDS e Redis.
- [x] Implementar e aplicar EKS e Node Group com a `LabRole` existente.
- [x] Instalar ArgoCD, External Secrets e Metrics Server via Terraform/Helm.
- [x] Integrar o External Secrets ao Secrets Manager.
- [x] Criar rotina segura para renovar credenciais temporárias no Kubernetes.
- [x] Inicializar os três bancos com Jobs idempotentes.
- [x] Validar todos os recursos e dois nodes `Ready`.

## CI/CD e GitOps

- [x] Criar workflow reutilizável.
- [x] Criar workflow para cada um dos cinco serviços.
- [x] Configurar testes, lint, SAST, SCA e scan de container.
- [x] Configurar push no ECR com tag do commit.
- [x] Criar pasta `gitops/` com os cinco serviços.
- [x] Configurar commit automático da nova tag.
- [x] Configurar cinco Applications no ArgoCD.
- [x] Validar workflows com Actionlint.
- [x] Cadastrar os quatro secrets temporários no GitHub Actions.
- [x] Publicar as cinco imagens iniciais no ECR com SHA.
- [ ] Validar sincronização automática.
- [ ] Demonstrar falha de segurança e correção.

## Entrega — não iniciado

- [ ] Guardar evidências sem dados sensíveis.
- [ ] Criar estimativa de custos.
- [ ] Finalizar README.
- [ ] Criar relatório de entrega.
- [ ] Gravar vídeo de até 20 minutos.
- [ ] Revisar links e repositório.
- [ ] Destruir os recursos AWS depois da gravação/avaliação.

## Registro de validações

### 14/09/2026 — base local

- Docker Compose: aprovado.
- Cinco health checks: aprovados.
- Teste E2E: aprovado.
- Evento de avaliação consumido da fila e gravado no DynamoDB local: aprovado.
- Testes unitários: 21 aprovados.
- Lint Go/Python: aprovado.
- SAST Gosec/Bandit: aprovado.
- SCA Trivy, severidade crítica: nenhuma vulnerabilidade encontrada.
- Terraform `fmt` e `validate`: aprovados sem acessar a AWS.
- Arquivo sensível `fase_02/k8s/secrets.yaml`: não copiado.
- Recursos AWS criados: nenhum.

### 14/09/2026 — AWS Academy e automação

- Credenciais temporárias: validadas sem expor valores.
- Backend Terraform: S3 com criptografia, versionamento, bloqueio público e lock.
- Plano revisado: nenhum recurso IAM criado.
- Terraform: 50 recursos de infraestrutura e 3 charts Helm aplicados.
- EKS e Node Group: ativos, com dois nodes `Ready` e `LabRole` existente.
- Bancos: três RDS PostgreSQL disponíveis e inicializados.
- Dados e mensageria: Redis, DynamoDB, SQS e DLQ disponíveis.
- Imagens: cinco repositórios ECR e cinco imagens iniciais por SHA.
- Segredos: Secrets Manager e External Secrets sincronizados.
- Plataforma: ArgoCD, External Secrets e Metrics Server disponíveis.
- Segurança de containers: três CVEs críticas da imagem Python foram detectadas, corrigidas e os novos scans foram aprovados.
- Workflows: um reutilizável e cinco pipelines validados localmente com Actionlint.
