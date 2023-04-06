data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default_vpc_subnets_ids" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.value
}

locals {
  subnets_ids = [for s in data.aws_subnet.default_vpc_subnets_ids : s.id]
}

resource "aws_ecs_cluster" "n8n_cluster" {
  name = "n8n-services-cluster"
  tags = var.tags
}

resource "aws_security_group" "n8n_lb" {
  name        = "n8n-lb-sg"
  description = "ALB for n8n SG"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags   = var.tags
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "n8n_ecs_tasks_sg" {
  name        = "n8n-ecs-tasks-sg"
  description = "allow inbound access from the ALB only"

  ingress {
    protocol = "tcp"
    # n8n default port
    from_port       = 5678
    to_port         = 5678
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.n8n_lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = data.aws_vpc.default.id

  tags = var.tags
}

resource "aws_lb" "n8n_ecs_alb" {
  name               = "n8necsalb"
  subnets            = local.subnets_ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.n8n_lb.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "n8n_ecs_alb_tg" {
  name        = "n8necsalbtg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/healtz"
    unhealthy_threshold = "2"
  }

  tags = var.tags
}

resource "aws_lb_listener" "n8n_https_forward" {
  load_balancer_arn = aws_lb.n8n_ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_ecs_alb_tg.arn
  }

  tags = var.tags
}
