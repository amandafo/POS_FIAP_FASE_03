#!/usr/bin/env bash

# Carrega somente os tres campos de credencial temporaria copiados do AWS Academy.
# Use: source scripts/aws-academy-env.sh

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf '%s\n' "Execute com: source scripts/aws-academy-env.sh" >&2
  exit 1
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
credentials_file="${AWS_ACADEMY_CREDENTIALS_FILE:-${project_root}/credentials_aws_academy.txt}"

if [[ ! -s "$credentials_file" ]]; then
  printf 'Arquivo de credenciais ausente ou vazio: %s\n' "$credentials_file" >&2
  return 1
fi

extract_credential() {
  local wanted="$1"
  awk -F= -v wanted="$wanted" '
    {
      line=$0
      gsub(/\r/, "", line)
      sub(/^[[:space:]]*export[[:space:]]+/, "", line)
      key=line
      sub(/[[:space:]]*=.*/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      if (tolower(key) == tolower(wanted)) {
        value=line
        sub(/^[^=]*=/, "", value)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        if (substr(value, 1, 1) == "\"") value=substr(value, 2)
        if (substr(value, length(value), 1) == "\"") value=substr(value, 1, length(value)-1)
        if (substr(value, 1, 1) == sprintf("%c", 39)) value=substr(value, 2)
        if (substr(value, length(value), 1) == sprintf("%c", 39)) value=substr(value, 1, length(value)-1)
        print value
        exit
      }
    }
  ' "$credentials_file"
}

export AWS_ACCESS_KEY_ID="$(extract_credential aws_access_key_id)"
export AWS_SECRET_ACCESS_KEY="$(extract_credential aws_secret_access_key)"
export AWS_SESSION_TOKEN="$(extract_credential aws_session_token)"
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"

if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_SESSION_TOKEN" ]]; then
  printf '%s\n' "Nao foi possivel localizar todos os campos da credencial." >&2
  return 1
fi

unset -f extract_credential
unset project_root credentials_file
