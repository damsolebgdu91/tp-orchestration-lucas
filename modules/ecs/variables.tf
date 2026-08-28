variable "app_name" {
  description = "Nom logique de l'application (utilisé pour nommer les ressources)"
  type        = string
  default     = "lucas"
}

variable "container_image_tag" {
  description = "Tag de l'image applicative poussée dans ECR (jamais 'latest')"
  type        = string
}

variable "container_port" {
  description = "Port exposé par le conteneur applicatif"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Nombre de tâches ECS souhaitées (mise à l'échelle)"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "CPU Fargate (unités) pour la task definition"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Mémoire Fargate (MiB) pour la task definition"
  type        = string
  default     = "512"
}

variable "vpc_id" {
  description = "VPC AWS Academy par défaut à utiliser"
  type        = string
}

variable "subnet_ids" {
  description = "Sous-réseaux publics du VPC pour le service Fargate"
  type        = list(string)
}

# En AWS Academy, on NE crée PAS de rôle IAM : on réutilise LabRole,
# déjà provisionné par le labo, comme execution role ET task role.
variable "lab_role_arn" {
  description = "ARN du rôle LabRole imposé par AWS Academy"
  type        = string
}
