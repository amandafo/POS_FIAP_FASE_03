#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  printf 'Uso: %s <servico> <registry> <tag>\n' "$0" >&2
  exit 1
fi

service="$1"
registry="${2%/}"
tag="$3"
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kustomization="$project_root/gitops/apps/$service/kustomization.yaml"

case "$service" in
  auth-service|flag-service|targeting-service|evaluation-service|analytics-service) ;;
  *)
    printf 'Servico invalido: %s\n' "$service" >&2
    exit 1
    ;;
esac

if [[ ! "$tag" =~ ^[a-f0-9]{7,40}$ ]]; then
  printf 'A tag deve ser um commit SHA: %s\n' "$tag" >&2
  exit 1
fi

sed -i -E \
  -e "s|^[[:space:]]*newName:.*$|    newName: ${registry}/${service}|" \
  -e "s|^[[:space:]]*newTag:.*$|    newTag: ${tag}|" \
  "$kustomization"

printf 'GitOps atualizado: %s -> %s/%s:%s\n' "$service" "$registry" "$service" "$tag"
