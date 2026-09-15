#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
terraform_image="${TERRAFORM_IMAGE:-hashicorp/terraform:1.13.3}"

for variable in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_REGION; do
  if [[ -z "${!variable:-}" ]]; then
    printf 'Variavel obrigatoria ausente: %s\n' "$variable" >&2
    printf '%s\n' "Execute antes: source scripts/aws-academy-env.sh" >&2
    exit 1
  fi
done

exec docker run --rm -i \
  --user "$(id -u):$(id -g)" \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -e AWS_REGION \
  -e AWS_DEFAULT_REGION="$AWS_REGION" \
  -e HOME=/tmp \
  -e HELM_CACHE_HOME=/tmp/helm/cache \
  -e HELM_CONFIG_HOME=/tmp/helm/config \
  -e HELM_DATA_HOME=/tmp/helm/data \
  -v "$project_root:/workspace" \
  -w /workspace/infra \
  "$terraform_image" "$@"
