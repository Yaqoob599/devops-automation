pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "140023400586"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "docker-pipeline"
        IMAGE_TAG = "V2"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/dec-2025"
        SCANNER_HOME = tool 'sonar-scanner'
        CHART_NAME = "new1"  // Helm chart name
        NAMESPACE = "default"
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/Yaqoob599/devops-automation.git'
            }
        }
      
        stage('Build & Unit Test') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                        docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}
                        docker push ${REPOSITORY_URI}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes using Helm') {
            steps {
                withKubeConfig(
                    credentialsId: 'kubernetes', // Ensure this exists in Jenkins credentials
                    contextName: 'kubernetes-admin@kubernetes',
                    namespace: "${NAMESPACE}",
                    serverUrl: 'https://172.31.43.46:6443'
                ) {
                    sh """
                        helm upgrade --install ${CHART_NAME} .
                        --set image.repository=${REPOSITORY_URI} \
                        --set image.tag=${IMAGE_TAG} \
                        --namespace ${NAMESPACE}
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n ${NAMESPACE}"
            }
        }
    }

    post {
        success {
            echo "Deployment Successful!"
        }
        failure {
            echo " Deployment Failed!"
        }
    }
}
