terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  data = var.config_data
}

# ---------------------------------------------------------------------------
# Deployment : plusieurs réplicas, requests/limits définis (exigés pour que
# le HPA et metrics-server puissent calculer l'utilisation CPU), sondes de
# santé pour la résilience.
# ---------------------------------------------------------------------------
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = { app = var.app_name }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = var.app_name }
    }

    template {
      metadata {
        labels = { app = var.app_name }
      }

      spec {
        container {
          name  = var.app_name
          image = var.container_image # ex: registry/app:1.0.3 -- jamais "latest"

          port {
            container_port = var.container_port
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = var.app_name }
    port {
      port        = 80
      target_port = var.container_port
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# HorizontalPodAutoscaler : nécessite metrics-server actif dans Minikube
#   -> minikube addons enable metrics-server
# ---------------------------------------------------------------------------
resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    min_replicas = var.replicas
    max_replicas = var.replicas * 4

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Garde-fou de sécurité : politique Kyverno interdisant le tag "latest".
# Nécessite Kyverno installé au préalable dans le cluster :
#   kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "disallow_latest_tag" {
  yaml_body = <<-YAML
    apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    metadata:
      name: disallow-latest-tag
    spec:
      validationFailureAction: Enforce
      background: true
      rules:
        - name: require-image-tag
          match:
            any:
              - resources:
                  kinds:
                    - Pod
          validate:
            message: "Le tag d'image ':latest' est interdit, utilisez un tag explicite."
            pattern:
              spec:
                containers:
                  - image: "!*:latest"
  YAML
}
