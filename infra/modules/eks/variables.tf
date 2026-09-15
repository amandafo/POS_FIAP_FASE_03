variable "cluster_name" { type = string }
variable "lab_role_arn" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "kubernetes_version" {
  type     = string
  default  = null
  nullable = true
}
variable "node_instance_types" { type = list(string) }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "tags" {
  type    = map(string)
  default = {}
}
