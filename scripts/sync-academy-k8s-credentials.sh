#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=aws-academy-env.sh
source "$project_root/scripts/aws-academy-env.sh"

kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl create namespace togglemaster --dry-run=client -o yaml | kubectl apply -f - >/dev/null

create_credentials_secret() {
  local namespace="$1"
  local name="$2"

  kubectl create secret generic "$name" \
    --namespace "$namespace" \
    --from-literal=access-key-id="$AWS_ACCESS_KEY_ID" \
    --from-literal=secret-access-key="$AWS_SECRET_ACCESS_KEY" \
    --from-literal=session-token="$AWS_SESSION_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f - >/dev/null
}

create_credentials_secret external-secrets aws-academy-credentials
create_credentials_secret togglemaster aws-academy-workload-credentials

printf '%s\n' "Credenciais temporarias sincronizadas sem gravar valores em arquivo YAML."
