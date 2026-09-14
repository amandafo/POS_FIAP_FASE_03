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

## AWS Academy — não iniciado

- [ ] Iniciar nova sessão do laboratório.
- [ ] Renovar credenciais temporárias locais.
- [ ] Validar conta e `LabRole`.
- [ ] Criar bucket S3 para o state remoto.
- [ ] Implementar e aplicar módulo de rede.
- [ ] Implementar e aplicar cinco repositórios ECR.
- [ ] Implementar e aplicar SQS e DynamoDB.
- [ ] Implementar e aplicar três RDS e Redis.
- [ ] Implementar e aplicar EKS e Node Group com role existente.
- [ ] Instalar plataforma: ArgoCD, External Secrets e Metrics Server.
- [ ] Inicializar bancos e validar todos os recursos.

## CI/CD e GitOps — não iniciado

- [ ] Criar workflow reutilizável.
- [ ] Criar workflow para cada um dos cinco serviços.
- [ ] Configurar testes, lint, SAST, SCA e scan de container.
- [ ] Configurar push no ECR com tag do commit.
- [ ] Criar pasta `gitops/` com os cinco serviços.
- [ ] Configurar commit automático da nova tag.
- [ ] Configurar cinco Applications no ArgoCD.
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
