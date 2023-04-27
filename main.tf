terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.61.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }

  required_version = ">= 1.4.0"
}

locals {
  cw_logs_group = "awslogs-n8n-main"
  prefix        = "tutorial"
  tags = {
    Application      = "n8n"
    TerraformManaged = true
    Deployment       = local.prefix
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "aws_network_data" {
  source = "./modules/network"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.prefix}_n8n_postgres_sg"
  vpc_id      = module.aws_network_data.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.aws_network_data.vpc_cidr_block
    },
  ]

  tags = local.tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${local.prefix}n8npostgres"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.small"

  allocated_storage     = 20
  max_allocated_storage = 20

  db_name  = "n8n"
  username = "n8n"
  password = random_password.db_password.result
  port     = 5432

  tags = local.tags
}

module "app-deployment" {
  source = "./modules/ecs-fargate"

  prefix = local.prefix
  cw_logs_group = local.cw_logs_group
  container_definitions = templatefile("./n8n-task-def.tftlp", {
    docker_repository = "docker.n8n.io/n8nio/n8n"
    docker_tag        = "latest"
    port              = 5678
    aws_region        = var.aws_region
    cw_logs_group     = local.cw_logs_group
  })
  aws_vpc_id = module.aws_network_data.vpc_id
  subnets_ids = module.aws_network_data.subnets_ids

  tags = local.tags
}
