output "ecs_ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "k8s_namespace" {
  value = module.k8s.namespace
}

output "k8s_service_name" {
  value = module.k8s.service_name
}

output "k8s_hpa_name" {
  value = module.k8s.hpa_name
}

output "ecs_alb_url" {
  description = "URL publique de l'application ECS"
  value       = "http://${module.ecs.alb_dns_name}"
}
