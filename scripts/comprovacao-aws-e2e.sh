#!/usr/bin/env bash
set -euo pipefail

namespace="togglemaster"
table_name="ToggleMasterAnalytics"
flag_name="enable-new-dashboard"
test_run="$(date -u +%Y%m%dT%H%M%SZ)"
test_user="aws-e2e-${test_run}"
temp_dir="$(mktemp -d)"
forward_pids=()
step=0

section() {
  step=$((step + 1))
  printf '\n============================================================\n'
  printf 'ETAPA %02d — %s\n' "$step" "$1"
  printf '============================================================\n'
}

success() {
  printf '[OK] %s\n' "$1"
}

info() {
  printf '[INFO] %s\n' "$1"
}

pretty_json() {
  python3 -m json.tool 2>/dev/null || cat
}

cleanup() {
  for pid in "${forward_pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
  rm -rf "$temp_dir"
}
trap cleanup EXIT

start_forward() {
  local service="$1"
  local local_port="$2"
  local remote_port="$3"

  kubectl port-forward -n "$namespace" "service/$service" \
    "$local_port:$remote_port" >"$temp_dir/$service.log" 2>&1 &
  forward_pids+=("$!")
  info "$service: encaminhamento local 127.0.0.1:$local_port iniciado."
}

request_with_body() {
  local method="$1"
  local url="$2"
  local data="$3"
  local output_file="$4"

  curl --silent --show-error \
    --output "$output_file" \
    --write-out '%{http_code}' \
    --request "$method" \
    --header "Authorization: Bearer $api_key" \
    --header 'Content-Type: application/json' \
    --data "$data" \
    "$url"
}

section "Validando ferramentas e sessão AWS"

for command in aws kubectl curl python3 base64; do
  command -v "$command" >/dev/null || {
    printf '[ERRO] Comando ausente: %s\n' "$command" >&2
    exit 1
  }
  success "Comando disponível: $command"
done

for variable in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_REGION; do
  [[ -n "${!variable:-}" ]] || {
    printf '[ERRO] Variável ausente: %s. Execute source scripts/aws-academy-env.sh\n' \
      "$variable" >&2
    exit 1
  }
done

if ! aws sts get-caller-identity --query Arn --output text >/dev/null 2>&1; then
  printf '[ERRO] As credenciais do AWS Academy estão expiradas ou inválidas.\n' >&2
  printf '[AÇÃO] Inicie o Lab, renove credentials_aws_academy.txt e carregue o arquivo novamente.\n' >&2
  exit 1
fi
success "Sessão temporária do AWS Academy válida."
info "Região utilizada: $AWS_REGION"
info "Nenhuma credencial, ARN ou ID de conta será exibido por este teste."

if ! aws eks describe-cluster \
  --region "$AWS_REGION" \
  --name togglemaster-cluster \
  --query 'cluster.status' \
  --output text >/dev/null 2>&1; then
  printf '[ERRO] A sessão existe, mas o AWS Academy bloqueou o acesso ao EKS.\n' >&2
  printf '[AÇÃO] Inicie ou renove a sessão do Lab e carregue as novas credenciais.\n' >&2
  exit 1
fi
success "Permissão para consultar o cluster EKS confirmada."

if ! aws dynamodb describe-table \
  --region "$AWS_REGION" \
  --table-name "$table_name" \
  --query 'Table.TableStatus' \
  --output text >/dev/null 2>&1; then
  printf '[ERRO] A sessão existe, mas o AWS Academy bloqueou o acesso ao DynamoDB.\n' >&2
  printf '[AÇÃO] Inicie ou renove a sessão do Lab e carregue as novas credenciais.\n' >&2
  exit 1
fi
success "Permissão para consultar o DynamoDB confirmada."

section "Validando conexão com o EKS e estado das aplicações"

current_context="$(kubectl config current-context)"
info "Contexto Kubernetes selecionado: ${current_context##*/}"

node_count="$(kubectl get nodes --no-headers | awk '$2 == "Ready" {count++} END {print count+0}')"
[[ "$node_count" -ge 1 ]] || {
  printf '[ERRO] Nenhum node Ready foi encontrado.\n' >&2
  exit 1
}
success "$node_count node(s) do EKS em estado Ready."

printf '\nDeployments e réplicas disponíveis:\n'
deployments="$(kubectl get deployments -n "$namespace" --no-headers)"
printf '%s\n' "$deployments"

deployment_count="$(printf '%s\n' "$deployments" | awk 'NF {count++} END {print count+0}')"
unavailable_deployments="$(printf '%s\n' "$deployments" | awk '
  {
    split($2, ready, "/")
    if (ready[1] != ready[2] || $3 != ready[2] || $4 != ready[2]) count++
  }
  END {print count+0}
')"

[[ "$deployment_count" -eq 5 ]] || {
  printf '[ERRO] Esperados 5 deployments, mas foram encontrados %s.\n' \
    "$deployment_count" >&2
  exit 1
}

[[ "$unavailable_deployments" -eq 0 ]] || {
  printf '[ERRO] Existem deployments sem todas as réplicas disponíveis.\n' >&2
  exit 1
}
success "Cinco deployments com todas as réplicas disponíveis."

terminal_pods="$(kubectl get pods -n "$namespace" --no-headers \
  | awk '$3 == "Failed" || $3 == "Succeeded" {count++} END {print count+0}')"
if ((terminal_pods > 0)); then
  info "$terminal_pods pod(s) antigo(s) já encerrado(s) foram ignorados na validação."
fi

printf '\nPods ativos das aplicações antes do teste:\n'
kubectl get pods -n "$namespace" --field-selector=status.phase=Running \
  -o custom-columns='NOME:.metadata.name,READY:.status.containerStatuses[0].ready,STATUS:.status.phase,REINICIOS:.status.containerStatuses[0].restartCount'

running_count="$(kubectl get pods -n "$namespace" \
  --field-selector=status.phase=Running --no-headers | awk 'NF {count++} END {print count+0}')"
[[ "$running_count" -ge 6 ]] || {
  printf '[ERRO] Esperados pelo menos 6 pods ativos, mas foram encontrados %s.\n' \
    "$running_count" >&2
  exit 1
}
success "$running_count pods ativos em estado Running."

section "Abrindo acesso temporário aos cinco microsserviços"

start_forward auth-service 18001 8001
start_forward flag-service 18002 8002
start_forward targeting-service 18003 8003
start_forward evaluation-service 18004 80
start_forward analytics-service 18005 8005

success "Cinco encaminhamentos iniciados somente em localhost."

section "Executando os cinco health checks"

health_services=(
  "auth-service:18001"
  "flag-service:18002"
  "targeting-service:18003"
  "evaluation-service:18004"
  "analytics-service:18005"
)

for entry in "${health_services[@]}"; do
  service="${entry%%:*}"
  port="${entry##*:}"
  response="$(curl --retry 30 --retry-delay 1 --retry-connrefused \
    --fail --silent "http://127.0.0.1:$port/health")"
  printf '[OK] %-20s respondeu: %s\n' "$service" "$response"
done

success "Health checks dos cinco microsserviços aprovados."

section "Obtendo a chave interna da aplicação com segurança"

api_key="$(kubectl get secret togglemaster-application-secret -n "$namespace" \
  -o jsonpath='{.data.SERVICE_API_KEY}' | base64 --decode)"

[[ -n "$api_key" ]] || {
  printf '[ERRO] A chave interna da aplicação está vazia.\n' >&2
  exit 1
}
success "Chave interna encontrada no Secret Kubernetes."
info "O valor da chave não será impresso nem salvo pelo script."

section "Configurando a feature flag"

flag_body="$temp_dir/flag.json"
flag_status="$(request_with_body POST \
  'http://127.0.0.1:18002/flags' \
  "{\"name\":\"$flag_name\",\"description\":\"Flag do teste E2E AWS\",\"is_enabled\":true}" \
  "$flag_body")"

case "$flag_status" in
  201)
    success "Feature flag criada para esta demonstração."
    ;;
  409)
    info "A feature flag já existia; ela será atualizada e reutilizada."
    ;;
  *)
    printf '[ERRO] Não foi possível criar a flag. HTTP %s\n' "$flag_status" >&2
    pretty_json <"$flag_body" >&2
    exit 1
    ;;
esac

flag_status="$(request_with_body PUT \
  "http://127.0.0.1:18002/flags/$flag_name" \
  '{"description":"Flag do teste E2E AWS","is_enabled":true}' \
  "$flag_body")"

[[ "$flag_status" == "200" ]] || {
  printf '[ERRO] Não foi possível ativar a flag. HTTP %s\n' "$flag_status" >&2
  pretty_json <"$flag_body" >&2
  exit 1
}

success "Feature flag ativa e pronta para avaliação:"
pretty_json <"$flag_body"

section "Configurando a regra de targeting"

rule_body="$temp_dir/rule.json"
rule_status="$(request_with_body POST \
  'http://127.0.0.1:18003/rules' \
  "{\"flag_name\":\"$flag_name\",\"rules\":{\"type\":\"PERCENTAGE\",\"value\":100},\"is_enabled\":true}" \
  "$rule_body")"

case "$rule_status" in
  201)
    success "Regra de targeting criada para esta demonstração."
    ;;
  409)
    info "A regra de targeting já existia; ela será atualizada e reutilizada."
    ;;
  *)
    printf '[ERRO] Não foi possível criar a regra. HTTP %s\n' "$rule_status" >&2
    pretty_json <"$rule_body" >&2
    exit 1
    ;;
esac

rule_status="$(request_with_body PUT \
  "http://127.0.0.1:18003/rules/$flag_name" \
  '{"rules":{"type":"PERCENTAGE","value":100},"is_enabled":true}' \
  "$rule_body")"

[[ "$rule_status" == "200" ]] || {
  printf '[ERRO] Não foi possível ativar a regra. HTTP %s\n' "$rule_status" >&2
  pretty_json <"$rule_body" >&2
  exit 1
}

success "Regra ativa, liberando a flag para 100% dos usuários:"
pretty_json <"$rule_body"

unset api_key
info "Chave interna removida da memória do script após a configuração."

section "Registrando o estado do DynamoDB antes da avaliação"

before_count="$(aws dynamodb scan \
  --table-name "$table_name" \
  --select COUNT \
  --consistent-read \
  --query Count \
  --output text)"

success "Tabela $table_name acessível."
info "Quantidade de eventos antes do teste: $before_count"
info "Identificador desta execução: $test_run"
info "Usuário único usado nesta execução: $test_user"

section "Avaliando a flag para o usuário de teste"

evaluation="$(curl --fail --silent --show-error \
  "http://127.0.0.1:18004/evaluate?user_id=$test_user&flag_name=$flag_name")"

printf 'Resposta recebida do evaluation-service:\n'
printf '%s' "$evaluation" | pretty_json

EXPECTED_USER="$test_user" EVALUATION_JSON="$evaluation" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["EVALUATION_JSON"])
assert payload["flag_name"] == "enable-new-dashboard"
assert payload["user_id"] == os.environ["EXPECTED_USER"]
assert payload["result"] is True
PY

unset evaluation
success "Decisão positiva validada: a flag foi liberada para o usuário."
info "Ao responder, o evaluation-service também publicou um evento no SQS."

section "Aguardando SQS e analytics processarem o evento"

after_count="$before_count"
for attempt in $(seq 1 30); do
  after_count="$(aws dynamodb scan \
    --table-name "$table_name" \
    --select COUNT \
    --consistent-read \
    --query Count \
    --output text)"

  printf '[INFO] Verificação %02d/30: eventos antes=%s, agora=%s\n' \
    "$attempt" "$before_count" "$after_count"

  if ((after_count > before_count)); then
    break
  fi
  sleep 2
done

if ((after_count <= before_count)); then
  printf '[ERRO] O evento não apareceu no DynamoDB dentro do prazo.\n' >&2
  exit 1
fi

success "A quantidade de eventos aumentou de $before_count para $after_count."
success "O analytics-service consumiu o evento do SQS e gravou no DynamoDB."

section "Localizando o evento exato criado por esta execução"

expression_values="$(printf \
  '{\":flag\":{\"S\":\"%s\"},\":user\":{\"S\":\"%s\"}}' \
  "$flag_name" "$test_user")"

event="$(aws dynamodb scan \
  --table-name "$table_name" \
  --consistent-read \
  --filter-expression 'flag_name = :flag AND user_id = :user' \
  --expression-attribute-values "$expression_values" \
  --query 'Items[0].{event_id:event_id.S,user_id:user_id.S,flag_name:flag_name.S,result:result.BOOL,timestamp:timestamp.S}' \
  --output json)"

EVENT_JSON="$event" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["EVENT_JSON"])
assert payload is not None
assert payload["flag_name"] == "enable-new-dashboard"
assert payload["result"] is True
PY

printf 'Evento confirmado no DynamoDB:\n'
printf '%s' "$event" | pretty_json
success "Evento desta execução localizado pelo usuário único."

section "Exibindo logs seguros do processamento"

printf 'evaluation-service — envio para o SQS:\n'
kubectl logs -n "$namespace" \
  -l app.kubernetes.io/name=evaluation-service \
  --all-containers=true --prefix=true --since=5m 2>/dev/null \
  | grep -E 'Evento de avaliação enviado para SQS' | tail -5 \
  || info "Linha de envio não encontrada no recorte recente dos logs."

printf '\nanalytics-service — consumo e gravação:\n'
kubectl logs -n "$namespace" \
  -l app.kubernetes.io/name=analytics-service \
  --all-containers=true --prefix=true --since=5m 2>/dev/null \
  | grep -E 'Recebidas [0-9]+ mensagens|salvo no DynamoDB' | tail -8 \
  || info "Linhas de consumo não encontradas no recorte recente dos logs."

section "Resultado final"

printf 'Fluxo comprovado:\n'
printf '  1. EKS e pods disponíveis.\n'
printf '  2. Cinco health checks aprovados.\n'
printf '  3. Chave interna obtida sem exposição.\n'
printf '  4. Feature flag ativa.\n'
printf '  5. Regra de targeting ativa para 100%% dos usuários.\n'
printf '  6. Evaluation-service retornou true.\n'
printf '  7. Evento publicado no SQS.\n'
printf '  8. Analytics-service consumiu o evento.\n'
printf '  9. Evento localizado no DynamoDB.\n\n'
printf 'Teste E2E AWS: APROVADO.\n'
