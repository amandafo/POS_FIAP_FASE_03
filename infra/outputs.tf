output "aws_account_id" {
  description = "ID da conta atual, consultado dinamicamente."
  value       = data.aws_caller_identity.current.account_id
}

output "lab_role_arn" {
  description = "ARN da LabRole existente; o Terraform nao cria IAM."
  value       = data.aws_iam_role.lab_role.arn
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "sqs_queue_url" {
  value = module.messaging.queue_url
}

output "dynamodb_table_name" {
  value = module.messaging.dynamodb_table_name
}

output "rds_endpoints" {
  value     = module.databases.rds_endpoints
  sensitive = true
}

output "redis_endpoint" {
  value = module.databases.redis_endpoint
}

output "secrets_manager_names" {
  value = module.databases.secret_names
}
