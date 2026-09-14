.PHONY: local-up local-down health e2e test test-go test-python lint lint-go lint-python sast sast-go sast-python sca terraform-fmt terraform-check

GO_IMAGE ?= golang:1.26-alpine
PYTHON_IMAGE ?= python:3.11-slim
TERRAFORM_IMAGE ?= hashicorp/terraform:1.13.3

local-up:
	docker compose up --build -d

local-down:
	docker compose down

health:
	@for port in 8001 8002 8003 8004 8005; do \
		printf 'porta %s: ' "$$port"; \
		curl --retry 20 --retry-delay 1 --retry-connrefused -fsS "http://localhost:$$port/health"; \
		printf '\n'; \
	done

e2e:
	./scripts/comprovacao-e2e.sh

test: test-go test-python

test-go:
	docker run --rm -v "$(CURDIR)/auth-service:/src" -w /src $(GO_IMAGE) go test ./...
	docker run --rm -v "$(CURDIR)/evaluation-service:/src" -w /src $(GO_IMAGE) go test ./...

test-python:
	@for service in flag-service targeting-service analytics-service; do \
		docker run --rm -v "$(CURDIR)/$$service:/app" -w /app $(PYTHON_IMAGE) \
			sh -c 'pip install --quiet --disable-pip-version-check -r requirements.txt pytest && pytest -q' || exit 1; \
	done

lint: lint-go lint-python

lint-go:
	docker run --rm -v "$(CURDIR)/auth-service:/app" -w /app golangci/golangci-lint:latest golangci-lint run ./...
	docker run --rm -v "$(CURDIR)/evaluation-service:/app" -w /app golangci/golangci-lint:latest golangci-lint run ./...

lint-python:
	docker run --rm -v "$(CURDIR):/workspace" -w /workspace $(PYTHON_IMAGE) \
		sh -c 'pip install --quiet --disable-pip-version-check ruff && ruff check flag-service targeting-service analytics-service'

sast: sast-go sast-python

sast-go:
	docker run --rm -v "$(CURDIR)/auth-service:/app" -w /app securego/gosec:latest -severity medium -confidence medium ./...
	docker run --rm -v "$(CURDIR)/evaluation-service:/app" -w /app securego/gosec:latest -severity medium -confidence medium ./...

sast-python:
	docker run --rm -v "$(CURDIR):/workspace" -w /workspace $(PYTHON_IMAGE) \
		sh -c 'pip install --quiet --disable-pip-version-check bandit && bandit -r flag-service targeting-service analytics-service -x "*/tests/*"'

sca:
	docker run --rm -v "$(CURDIR):/workspace" -w /workspace aquasec/trivy:latest \
		fs --scanners vuln --severity CRITICAL --exit-code 1 --skip-dirs .git /workspace

terraform-fmt:
	docker run --rm --user "$$(id -u):$$(id -g)" -v "$(CURDIR):/workspace" -w /workspace/infra $(TERRAFORM_IMAGE) fmt -recursive

terraform-check:
	docker run --rm --user "$$(id -u):$$(id -g)" -v "$(CURDIR):/workspace" -w /workspace/infra $(TERRAFORM_IMAGE) fmt -check -recursive
	docker run --rm --user "$$(id -u):$$(id -g)" -v "$(CURDIR):/workspace" -w /workspace/infra $(TERRAFORM_IMAGE) init -backend=false
	docker run --rm --user "$$(id -u):$$(id -g)" -v "$(CURDIR):/workspace" -w /workspace/infra $(TERRAFORM_IMAGE) validate
