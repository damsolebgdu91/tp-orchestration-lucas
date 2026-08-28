terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# ---------------------------------------------------------------------------
# Provider AWS : identifiants de session temporaires AWS Academy
# (variables d'environnement AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY /
# AWS_SESSION_TOKEN -- jamais en dur ici ni dans Git).
# ---------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# Provider Kubernetes : cluster local Minikube (contexte "minikube").
# Les manifestes restent transposables tels quels vers EKS.
# ---------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

module "ecs" {
  source = "./modules/ecs"

  app_name            = var.app_name
  container_image_tag = var.ecs_image_tag
  desired_count       = var.ecs_desired_count
  vpc_id              = var.aws_vpc_id
  subnet_ids          = var.aws_subnet_ids
  lab_role_arn        = var.aws_lab_role_arn
}

module "k8s" {
  source = "./modules/k8s"

  app_name        = var.app_name
  container_image = var.k8s_container_image
  replicas        = var.k8s_replicas
}
