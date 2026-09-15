variable "aws_region" {
  description = "Regiao AWS usada pelo laboratorio."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome curto usado nos recursos e tags."
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Nome do ambiente."
  type        = string
  default     = "homolog"
}

variable "lab_role_name" {
  description = "Role existente fornecida pelo AWS Academy."
  type        = string
  default     = "LabRole"
}

variable "vpc_cidr" {
  description = "CIDR principal da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Duas zonas usadas pelas subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Informe exatamente duas zonas de disponibilidade."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs das duas subnets publicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Informe exatamente dois CIDRs publicos."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDRs das duas subnets privadas."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Informe exatamente dois CIDRs privados."
  }
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
  default     = "togglemaster-cluster"
}

variable "kubernetes_version" {
  description = "Versao do Kubernetes. Null usa a versao padrao atual do EKS."
  type        = string
  default     = null
  nullable    = true
}

variable "node_instance_types" {
  description = "Tipos de instancia permitidos no node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "db_instance_class" {
  description = "Classe pequena para as tres instancias RDS do laboratorio."
  type        = string
  default     = "db.t3.micro"
}

variable "redis_node_type" {
  description = "Classe pequena para o Redis do laboratorio."
  type        = string
  default     = "cache.t3.micro"
}

variable "service_names" {
  description = "Microsservicos que recebem repositorios ECR."
  type        = set(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ]
}

variable "sqs_queue_name" {
  type    = string
  default = "togglemaster-events"
}

variable "dynamodb_table_name" {
  type    = string
  default = "ToggleMasterAnalytics"
}

variable "install_platform" {
  description = "Instala ArgoCD, External Secrets e Metrics Server depois que o EKS estiver ativo."
  type        = bool
  default     = false
}
