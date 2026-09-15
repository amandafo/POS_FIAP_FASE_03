locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.eks_cluster_name
  tags                 = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = var.service_names
  tags             = local.common_tags
}

module "messaging" {
  source = "./modules/messaging"

  queue_name          = var.sqs_queue_name
  dynamodb_table_name = var.dynamodb_table_name
  tags                = local.common_tags
}

module "databases" {
  source = "./modules/databases"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  vpc_cidr           = module.network.vpc_cidr
  private_subnet_ids = module.network.private_subnet_ids
  db_instance_class  = var.db_instance_class
  redis_node_type    = var.redis_node_type
  tags               = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.eks_cluster_name
  lab_role_arn        = data.aws_iam_role.lab_role.arn
  private_subnet_ids  = module.network.private_subnet_ids
  kubernetes_version  = var.kubernetes_version
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  tags                = local.common_tags
}

module "platform" {
  source = "./modules/platform"

  enabled = var.install_platform

  providers = {
    helm = helm
  }

  depends_on = [module.eks]
}
