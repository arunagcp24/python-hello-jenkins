pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'project-51b9a3dd-ce80-4752-b31'
        GAR_LOCATION = 'asia-south1'
        GAR_REPO = 'dbt-docker-repo'
        IMAGE_NAME = 'dbt-account-loader'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Setup GCP Authentication') {
            steps {
                echo 'Setting up GCP configuration...'
                bat '''
                    gcloud config set project %PROJECT_ID%
                    gcloud auth configure-docker %GAR_LOCATION%-docker.pkg.dev
                '''
            }
        }
        
        stage('Verify Docker') {
            steps {
                echo 'Verifying Docker is running...'
                bat '''
                    docker info
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                bat '''
                    docker build -t %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% .
                    docker tag %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:latest
                '''
            }
        }
        
        stage('Test dbt Project') {
            steps {
                echo 'Testing dbt project configuration...'
                bat '''
                    docker run --rm %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% dbt debug --project-dir /app/bq_analytics
                '''
            }
        }
        
        stage('Push to GAR') {
            steps {
                echo 'Pushing Docker image to Google Artifact Registry...'
                bat '''
                    docker push %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG%
                    docker push %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:latest
                '''
            }
        }
        
        stage('Cleanup Local Images') {
            steps {
                echo 'Cleaning up local Docker images...'
                bat '''
                    docker rmi %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% || exit 0
                    docker rmi %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:latest || exit 0
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
            echo "Docker image pushed to: ${GAR_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${GAR_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
