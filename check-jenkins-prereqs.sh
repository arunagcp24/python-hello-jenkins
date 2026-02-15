#!/bin/bash
# Quick Jenkins Setup Commands for Linux

echo "=== Checking Jenkins Prerequisites ==="

# 1. Check if Jenkins is Running
echo -e "\n1. Opening Jenkins in browser..."
xdg-open http://localhost:8080 2>/dev/null || open http://localhost:8080 2>/dev/null

# 2. Check Required Tools
echo -e "\n2. Checking Docker..."
docker --version

echo -e "\n3. Checking gcloud..."
gcloud --version

echo -e "\n4. Checking Git..."
git --version

echo -e "\n=== Prerequisites Check Complete ==="

# 3. Verify GAR Repository
echo -e "\n5. Verifying Google Artifact Registry..."
gcloud artifacts repositories describe dbt-docker-repo --location=asia-south1

# 4. Test Docker authentication
echo -e "\n6. Testing Docker authentication..."
docker pull asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest

echo -e "\n=== Jenkins Environment Ready! ==="
echo "Now configure Jenkins job as per JENKINS_SETUP_GUIDE.md"
