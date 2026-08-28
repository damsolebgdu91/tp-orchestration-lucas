variable "app_name" {
  type    = string
  default = "lucas"
}

variable "namespace" {
  type    = string
  default = "tp-orchestration"
}

variable "container_image" {
  description = "Image complète app:tag (jamais 'latest')"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "replicas" {
  description = "Nombre de réplicas de base (avant HPA)"
  type        = number
  default     = 2
}

variable "cpu_request" {
  type    = string
  default = "100m"
}

variable "cpu_limit" {
  type    = string
  default = "250m"
}

variable "memory_request" {
  type    = string
  default = "128Mi"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}

variable "config_data" {
  description = "Paires clé/valeur injectées dans le ConfigMap"
  type        = map(string)
  default = {
    APP_ENV = "academy-lab"
  }
}
