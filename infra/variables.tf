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
