pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "140023400586"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "docker-pipeline"
        IMAGE_TAG = "V2"
        REPOSITORY_URI = "140023400586.dkr.ecr.ap-south-1.amazonaws.com/dec-2025"
        EKS_CLUSTER_NAME = "eks-cluster"
        CHART_NAME = "new1"  // Helm chart name
        NAMESPACE = "default"
        DOCKER_REGISTRY = "https://index.docker.io/v1/"
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

        stage('Login to Docker') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_PASSWORD', 
                                                 usernameVariable: 'DOCKER_USER', 
                                                 passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin $DOCKER_REGISTRY
                    '''
                }
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

stage('Configure AWS CLI & Kubeconfig') {
    steps {
        withCredentials([file(credentialsId: 'K8S_CREDENTIALS', variable: 'KUBECONFIG_FILE')]) {
            sh '''
            export KUBECONFIG=/tmp/kubeconfig
            cp $KUBECONFIG_FILE $KUBECONFIG
            chmod 600 $KUBECONFIG
            aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $EKS_CLUSTER_NAME --kubeconfig $KUBECONFIG
            kubectl config current-context
            kubectl config view
            kubectl get nodes
            '''
        }
    }
}
      
        stage('Deploy Helm Chart') {
                steps {    
                    sh """
                        helm upgrade --install ${CHART_NAME} . \
                            --set image.repository=${REPOSITORY_URI} \
                            --set image.tag=${IMAGE_TAG} \
                            --namespace ${NAMESPACE} \
                            --debug
                    """
                    }

            }
        

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n ${NAMESPACE}"
            }
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
