#!/usr/bin/env bash
set -euo pipefail

for command in aws kubectl curl python3 base64; do
  command -v "$command" >/dev/null || {
    printf 'Comando ausente: %s\n' "$command" >&2
    exit 1
  }
done

for variable in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_REGION; do
  [[ -n "${!variable:-}" ]] || {
    printf 'Variavel ausente: %s. Execute source scripts/aws-academy-env.sh\n' "$variable" >&2
    exit 1
  }
done

namespace=togglemaster
temp_dir="$(mktemp -d)"
forward_pids=()

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
  kubectl port-forward -n "$namespace" "service/$service" "$local_port:$remote_port" \
    >"$temp_dir/$service.log" 2>&1 &
  forward_pids+=("$!")
}

start_forward auth-service 18001 8001
start_forward flag-service 18002 8002
start_forward targeting-service 18003 8003
start_forward evaluation-service 18004 80
start_forward analytics-service 18005 8005

for port in 18001 18002 18003 18004 18005; do
  curl --retry 30 --retry-delay 1 --retry-connrefused --fail --silent \
    "http://127.0.0.1:$port/health" >/dev/null
done
printf '%s\n' "Health checks: cinco servicos aprovados."

api_key="$(kubectl get secret togglemaster-application-secret -n "$namespace" \
  -o jsonpath='{.data.SERVICE_API_KEY}' | base64 --decode)"

curl --silent --output /dev/null \
  --header "Authorization: Bearer $api_key" \
  --header 'Content-Type: application/json' \
  --request POST \
  --data '{"name":"enable-new-dashboard","description":"Flag do teste E2E AWS","is_enabled":true}' \
  http://127.0.0.1:18002/flags || true

curl --fail --silent --output /dev/null \
  --header "Authorization: Bearer $api_key" \
  --header 'Content-Type: application/json' \
  --request PUT \
  --data '{"is_enabled":true}' \
  http://127.0.0.1:18002/flags/enable-new-dashboard

curl --silent --output /dev/null \
  --header "Authorization: Bearer $api_key" \
  --header 'Content-Type: application/json' \
  --request POST \
  --data '{"flag_name":"enable-new-dashboard","rules":{"type":"PERCENTAGE","value":100},"is_enabled":true}' \
  http://127.0.0.1:18003/rules || true

curl --fail --silent --output /dev/null \
  --header "Authorization: Bearer $api_key" \
  --header 'Content-Type: application/json' \
  --request PUT \
  --data '{"rules":{"type":"PERCENTAGE","value":100},"is_enabled":true}' \
  http://127.0.0.1:18003/rules/enable-new-dashboard

unset api_key
printf '%s\n' "Flag e regra de targeting: configuradas."

before_count="$(aws dynamodb scan --table-name ToggleMasterAnalytics --select COUNT --query Count --output text)"
evaluation="$(curl --fail --silent 'http://127.0.0.1:18004/evaluate?user_id=aws-e2e-user&flag_name=enable-new-dashboard')"
EVALUATION_JSON="$evaluation" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["EVALUATION_JSON"])
assert payload["flag_name"] == "enable-new-dashboard"
assert payload["user_id"] == "aws-e2e-user"
assert payload["result"] is True
PY
unset evaluation
printf '%s\n' "Evaluation service: decisao positiva aprovada."

for _ in $(seq 1 30); do
  after_count="$(aws dynamodb scan --table-name ToggleMasterAnalytics --select COUNT --query Count --output text)"
  if (( after_count > before_count )); then
    printf '%s\n' "SQS e analytics: evento consumido e gravado no DynamoDB."
    printf '%s\n' "Teste E2E AWS: APROVADO."
    exit 0
  fi
  sleep 2
done

printf '%s\n' "O evento nao apareceu no DynamoDB dentro do prazo." >&2
exit 1
