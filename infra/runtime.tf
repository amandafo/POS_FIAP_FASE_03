resource "aws_secretsmanager_secret" "runtime" {
  name                    = "togglemaster/homolog/runtime"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "runtime" {
  secret_id = aws_secretsmanager_secret.runtime.id
  secret_string = jsonencode({
    AWS_REGION            = var.aws_region
    AWS_SQS_URL           = module.messaging.queue_url
    AWS_DYNAMODB_TABLE    = module.messaging.dynamodb_table_name
    REDIS_URL             = module.databases.redis_endpoint
    FLAG_SERVICE_URL      = "http://flag-service:8002"
    TARGETING_SERVICE_URL = "http://targeting-service:8003"
    AUTH_SERVICE_URL      = "http://auth-service:8001"
  })
}
