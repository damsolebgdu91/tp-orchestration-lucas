output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "hpa_name" {
  value = kubernetes_horizontal_pod_autoscaler_v2.app.metadata[0].name
}
