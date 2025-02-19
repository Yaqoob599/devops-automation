
pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "140023400586"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "docker-pipeline"
        IMAGE_TAG = "AB1"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/dec-2025"
		    SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/Yaqoob599/devops-automation.git'
            }
        }
      
		stage('building artifact and unit testing'){
		    steps{
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
        

        stage('deploying to kubernetes') {
    steps {
        withKubeConfig(
            caCertificate: '', // Optional if credentialsId includes this
            clusterName: 'kubernetes',
            contextName: 'kubernetes-admin@kubernetes', // Provide valid context name
            credentialsId: 'kubernetes', // Ensure this exists in Jenkins credentials
            namespace: 'default',
            restrictKubeConfigAccess: false,
            serverUrl: 'https://172.31.43.46:6443' // Ensure no spaces or invalid characters
        ) {
            sh '''
                kubectl apply -f deploymentservice.yaml
            '''
        }
    }
}
    }
}
