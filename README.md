# TP Orchestration automatisée — ECS et Kubernetes

Déploiement d'une même application sur Amazon ECS (Fargate, AWS Academy) et sur
Kubernetes (Minikube), industrialisé via Terraform + Jenkins.

## Architecture

```
Git ──▶ Jenkins ──▶ Terraform ──┬──▶ Amazon ECS (Fargate, us-east-1)
                                 └──▶ Kubernetes (Minikube)
```

Un seul `terraform apply` (piloté par le pipeline Jenkins) provisionne les deux
cibles. Voir `modules/ecs` et `modules/k8s`.

## Prérequis

- Terraform >= 1.5
- AWS CLI configuré avec les identifiants de session temporaires AWS Academy
- Minikube démarré : `minikube start`
- Addon metrics-server activé : `minikube addons enable metrics-server`
- Ingress controller nginx activé : `minikube addons enable ingress`
- Kyverno installé dans le cluster :
  `kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml`
- Jenkins avec les plugins Pipeline, Credentials Binding, AWS Steps

## Récupérer les informations AWS Academy

```bash
# VPC par défaut
aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' --output text

# Sous-réseaux du VPC par défaut
aws ec2 describe-subnets --filters Name=vpc-id,Values=<VPC_ID> \
  --query 'Subnets[].SubnetId' --output text

# ARN de LabRole
aws iam get-role --role-name LabRole --query 'Role.Arn' --output text
```

## Exécution locale (avant intégration Jenkins)

```bash
cp terraform.tfvars.example terraform.tfvars
# éditer terraform.tfvars avec vos valeurs (VPC, subnets, LabRole, image)

terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Exécution via Jenkins

1. Créer un pipeline Jenkins pointant sur ce dépôt (le `Jenkinsfile` est à la racine).
2. Déclarer 3 credentials Jenkins (type "Secret text") :
   `aws-academy-access-key-id`, `aws-academy-secret-access-key`,
   `aws-academy-session-token`.
3. Lancer le build : `Validate` → `Plan` → **approbation manuelle** → `Apply`.
4. Le plan est rejoué à l'identique tant que rien n'a changé (idempotence) :
   un second build sans modification affiche `No changes`.

## Vérifier le déploiement

```bash
# ECS
aws ecs describe-services --cluster lucas-ecs --services lucas --region us-east-1

# Kubernetes
kubectl -n tp-orchestration get deployment,svc,ingress,hpa
```

## Démonstration de la mise à l'échelle

```bash
# ECS : le service Application Auto Scaling réagit à la charge CPU (cible 60%)
# Générer de la charge, puis observer :
aws ecs describe-services --cluster lucas-ecs --services lucas \
  --query 'services[0].desiredCount'

# Kubernetes : le HPA réagit à la charge CPU (cible 60%)
kubectl -n tp-orchestration get hpa -w
```

## Sécurité mise en place

| Contrôle | ECS | Kubernetes |
|---|---|---|
| Moindre privilège | `LabRole` réutilisé, aucun rôle IAM créé | RBAC par défaut du namespace dédié |
| Réseau restreint | Security Group limité au port applicatif | NetworkPolicy / Ingress nginx |
| Pas de secret en dur | Identifiants via Jenkins Credentials | `terraform.tfvars` dans `.gitignore` |
| Image jamais `latest` | Tag ECR immuable (`IMMUTABLE`) | Politique Kyverno `disallow-latest-tag` |

## Structure du dépôt

```
.
├── main.tf                  # racine, providers aws + kubernetes
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── Jenkinsfile
├── modules/
│   ├── ecs/                 # ECR, cluster Fargate, service, scaling
│   └── k8s/                 # Deployment, Service, Ingress, HPA, Kyverno
└── README.md
```

## Répartition des tâches (à compléter si binôme)

- Étudiant 1 :
- Étudiant 2 :
