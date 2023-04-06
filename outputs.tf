output "app_url" {
    description = "deployed service url"
    value = aws_lb.n8n_ecs_alb.dns_name
}