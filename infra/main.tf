locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Os módulos serão conectados aqui na etapa AWS, nesta ordem:
# network, ecr, messaging, databases, eks e platform.
