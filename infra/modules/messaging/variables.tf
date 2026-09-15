variable "queue_name" { type = string }
variable "dynamodb_table_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
