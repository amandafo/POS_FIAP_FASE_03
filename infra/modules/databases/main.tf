locals {
  databases = {
    auth = {
      database_name = "auth_db"
      secret_name   = "togglemaster/homolog/auth-db"
    }
    flag = {
      database_name = "flags_db"
      secret_name   = "togglemaster/homolog/flag-db"
    }
    targeting = {
      database_name = "targeting_db"
      secret_name   = "togglemaster/homolog/targeting-db"
    }
  }

  db_username = "togglemaster"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name_prefix}-rds" })
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-redis"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "postgres" {
  name        = "${var.name_prefix}-postgres"
  description = "PostgreSQL acessivel somente dentro da VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL interno"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-postgres" })
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis"
  description = "Redis acessivel somente dentro da VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis interno"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-redis" })
}

resource "random_password" "database" {
  for_each = local.databases

  length  = 28
  special = false
}

resource "random_password" "master_key" {
  length  = 40
  special = false
}

resource "random_password" "service_api_key" {
  length  = 48
  special = false
}

resource "aws_db_instance" "this" {
  for_each = local.databases

  identifier                 = "${var.name_prefix}-${each.key}"
  engine                     = "postgres"
  engine_version             = "16"
  instance_class             = var.db_instance_class
  allocated_storage          = 20
  max_allocated_storage      = 40
  storage_type               = "gp3"
  storage_encrypted          = true
  db_name                    = each.value.database_name
  username                   = local.db_username
  password                   = random_password.database[each.key].result
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.postgres.id]
  publicly_accessible        = false
  multi_az                   = false
  skip_final_snapshot        = true
  deletion_protection        = false
  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}" })
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name_prefix}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.redis.id]
  apply_immediately    = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-redis" })
}

resource "aws_secretsmanager_secret" "database" {
  for_each = local.databases

  name                    = each.value.secret_name
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "database" {
  for_each = local.databases

  secret_id = aws_secretsmanager_secret.database[each.key].id
  secret_string = jsonencode({
    username     = local.db_username
    password     = random_password.database[each.key].result
    host         = aws_db_instance.this[each.key].address
    port         = aws_db_instance.this[each.key].port
    database     = each.value.database_name
    DATABASE_URL = "postgres://${local.db_username}:${random_password.database[each.key].result}@${aws_db_instance.this[each.key].address}:${aws_db_instance.this[each.key].port}/${each.value.database_name}?sslmode=require"
  })
}

resource "aws_secretsmanager_secret" "application" {
  name                    = "togglemaster/homolog/application"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "application" {
  secret_id = aws_secretsmanager_secret.application.id
  secret_string = jsonencode({
    MASTER_KEY      = random_password.master_key.result
    SERVICE_API_KEY = "tm_key_${random_password.service_api_key.result}"
  })
}
