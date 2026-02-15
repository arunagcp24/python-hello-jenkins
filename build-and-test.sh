#!/bin/bash
# Build and run dbt Docker container locally for testing

# Set variables
PROJECT_ID="project-51b9a3dd-ce80-4752-b31"
GAR_LOCATION="asia-south1"
GAR_REPO="dbt-docker-repo"
IMAGE_NAME="dbt-account-loader"
IMAGE_TAG="local-test"

echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Testing dbt debug..."
docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} dbt debug --project-dir /app/bq_analytics

echo "Running dbt model..."
docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} dbt run --models account_info --project-dir /app/bq_analytics

echo "Done!"
