output "ecr_repository_url" {
  description = "URL du dépôt ECR (à utiliser dans la CI pour push l'image)"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "URL publique de l'application (http://<valeur>)"
  value       = aws_lb.app.dns_name
}
