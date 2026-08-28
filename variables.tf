variable "app_name" {
  description = "Nom logique commun aux deux déploiements"
  type        = string
  default     = "lucas"
}

# --- ECS ---------------------------------------------------------------

variable "ecs_image_tag" {
  description = "Tag de l'image applicative dans ECR (ex: 1.0.3), jamais 'latest'"
  type        = string
}

variable "ecs_desired_count" {
  type    = number
  default = 2
}

variable "aws_vpc_id" {
  description = "VPC par défaut fourni par AWS Academy (voir README pour le récupérer)"
  type        = string
}

variable "aws_subnet_ids" {
  description = "Sous-réseaux publics du VPC par défaut AWS Academy"
  type        = list(string)
}

variable "aws_lab_role_arn" {
  description = "ARN de LabRole, ex: arn:aws:iam::<account_id>:role/LabRole"
  type        = string
}

# --- Kubernetes ----------------------------------------------------------

variable "k8s_container_image" {
  description = "Image complète app:tag pour le Deployment Kubernetes"
  type        = string
}

variable "k8s_replicas" {
  type    = number
  default = 2
}
