output "aws_account_id" {
  description = "ID da conta atual, consultado dinamicamente."
  value       = data.aws_caller_identity.current.account_id
}

output "lab_role_arn" {
  description = "ARN da LabRole existente; o Terraform nao cria IAM."
  value       = data.aws_iam_role.lab_role.arn
}
