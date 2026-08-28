pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        TF_IN_AUTOMATION = "true"
        AWS_ACCESS_KEY_ID     = credentials('aws-academy-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-academy-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-academy-session-token')

        TF_VAR_aws_vpc_id       = credentials('aws-vpc-id')
        TF_VAR_aws_subnet_ids   = credentials('aws-subnet-ids')
        TF_VAR_aws_lab_role_arn = credentials('aws-lab-role-arn')

        TF_VAR_ecs_image_tag       = "1.0.0"
        TF_VAR_k8s_container_image = "web-lucas:1.0.0"
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
                sh 'terraform plan -input=false -out=tfplan'
            }
        }

        stage('Approbation humaine') {
            steps {
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
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
        failure {
            echo 'Pipeline en échec : consulter les logs de la stage concernée.'
        }
    }
}
