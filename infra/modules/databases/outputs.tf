output "rds_endpoints" {
  value = { for name, database in aws_db_instance.this : name => database.endpoint }
}

output "redis_endpoint" {
  value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"
}

output "secret_names" {
  value = {
    for name, secret in aws_secretsmanager_secret.database : name => secret.name
  }
}

output "application_secret_name" {
  value = aws_secretsmanager_secret.application.name
}
