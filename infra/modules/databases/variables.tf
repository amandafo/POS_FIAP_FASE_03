variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_instance_class" { type = string }
variable "redis_node_type" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
