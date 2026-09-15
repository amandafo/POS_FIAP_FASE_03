variable "enabled" {
  description = "Permite instalar os charts somente depois que o EKS estiver disponivel."
  type        = bool
  default     = false
}
