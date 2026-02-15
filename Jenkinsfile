pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'project-51b9a3dd-ce80-4752-b31'
        GAR_LOCATION = 'asia-south1'
        GAR_REPO = 'dbt-docker-repo'
        IMAGE_NAME = 'dbt-account-loader'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-application-credentials')
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
                echo 'Setting up GCP configuration and Docker authentication...'
                bat '''
                    echo Credentials file: %GOOGLE_APPLICATION_CREDENTIALS%
                    set GOOGLE_APPLICATION_CREDENTIALS=%GOOGLE_APPLICATION_CREDENTIALS%
                    gcloud config set project %PROJECT_ID%
                    gcloud auth application-default print-access-token > token.txt
                    type token.txt | docker login -u oauth2accesstoken --password-stdin https://%GAR_LOCATION%-docker.pkg.dev
                    del token.txt
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
