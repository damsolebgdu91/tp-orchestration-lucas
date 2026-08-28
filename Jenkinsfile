pipeline {
    agent any

    options {
        // Empêche deux exécutions concurrentes d'appliquer en même temps
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        TF_IN_AUTOMATION = "true"
        // Identifiants AWS Academy (temporaires) injectés via Jenkins Credentials,
        // jamais en dur dans ce fichier.
        AWS_ACCESS_KEY_ID     = credentials('aws-academy-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-academy-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-academy-session-token')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                    terraform validate
                '''
            }
        }

        stage('Plan (ECS + Kubernetes)') {
            steps {
                sh 'terraform plan -input=false -out=tfplan -var-file=terraform.tfvars'
            }
        }

        stage('Approbation humaine') {
            steps {
                // Le plan couvre les DEUX cibles : rien n'est appliqué sans validation.
                input message: 'Appliquer le plan ECS + Kubernetes ?', ok: 'Déployer'
            }
        }

        stage('Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }

        stage('Vérification post-déploiement') {
            parallel {
                stage('Vérifier ECS') {
                    steps {
                        sh '''
                            aws ecs describe-services \
                              --cluster $(terraform output -raw ecs_cluster_name) \
                              --services $(terraform output -raw ecs_service_name) \
                              --region us-east-1
                        '''
                    }
                }
                stage('Vérifier Kubernetes') {
                    steps {
                        sh '''
                            kubectl --context minikube -n $(terraform output -raw k8s_namespace) \
                              get deployment,svc,hpa
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Le plan est idempotent : on l'archive pour traçabilité (partie 4.4)
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
        failure {
            echo 'Pipeline en échec : consulter les logs de la stage concernée.'
        }
    }
}
