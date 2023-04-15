resource "aws_cloudwatch_log_group" "n8n_main" {
  name = var.cw_logs_group
  tags = var.tags
}

resource "aws_ecs_task_definition" "n8n_main_task_definition" {
  family                   = "${var.prefix}_n8n_task_family"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.n8n_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  tags                     = var.tags
}

resource "aws_ecs_service" "n8n_main_service" {
  name            = "${var.prefix}_n8n_main_service"
  cluster         = aws_ecs_cluster.n8n_cluster.id
  task_definition = aws_ecs_task_definition.n8n_main_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.n8n_ecs_tasks_sg.id]
    subnets          = local.subnets_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.n8n_ecs_alb_tg.arn
    container_name   = "n8n"
    container_port   = var.app_port
  }

  depends_on = [
    aws_lb_listener.n8n_https_forward,
    aws_iam_role_policy_attachment.n8n_task_execution_role_attach_ecs_secrets_access,
    aws_iam_role_policy_attachment.n8n_task_execution_role_attach_ecs_task_policy,
  ]

  tags = var.tags
}

