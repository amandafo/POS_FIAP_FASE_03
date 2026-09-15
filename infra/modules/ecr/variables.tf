variable "repository_names" { type = set(string) }
variable "tags" {
  type    = map(string)
  default = {}
}
