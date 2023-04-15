variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type = map
  description = "tags added to all the created resources"
  default = {
    Application = "n8n"
    TerraformManaged = true
    CreatedBy = "ecs-fargate-module"
  }
}

variable "app_port" {
  type = number
  description = "n8n application port"
  default = 5678
}

variable "prefix" {
  type = string
  description = "This variable will prefix all resources name to easly reconize different deployments"
}

variable "cw_logs_group" {
  type = string
  description = "Target log group, should be the same that the container definition"
}

variable "container_definitions" {
  type = string
  description = "Container definition for aws_ecs_task_definition"
}