terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.61.0"
    }
  }

  required_version = ">= 1.4.0"
}

locals {
  cw_logs_group = "awslogs-n8n-main"
  prefix        = "tutorial"
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
  region     = var.aws_region
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

  tags = {
    Application      = "n8n"
    TerraformManaged = true
    Deployment       = local.prefix
  }
}
