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
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                bat '''
                    docker build -t %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% .
                    docker tag %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:%IMAGE_TAG% %GAR_LOCATION%-docker.pkg.dev/%PROJECT_ID%/%GAR_REPO%/%IMAGE_NAME%:latest
                '''
            }
        }
        
        stage('Build Notification') {
            steps {
                echo 'Docker image built successfully!'
                echo "Image: ${env.GAR_LOCATION}-docker.pkg.dev/${env.PROJECT_ID}/${env.GAR_REPO}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                echo "To push: Run push-to-gar.ps1 script from your terminal"
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
            echo "Docker image built: ${GAR_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${GAR_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
            echo "To push to GAR, run: .\\push-to-gar.ps1"
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Jenkins build complete'
        }
    }
}
