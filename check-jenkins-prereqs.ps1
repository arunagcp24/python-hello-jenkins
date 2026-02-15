# Quick Jenkins Setup Commands

## 1. Check if Jenkins is Running
Start-Process "http://localhost:8080"

## 2. Check Required Tools on Jenkins Agent
Write-Host "Checking Docker..." -ForegroundColor Yellow
docker --version

Write-Host "`nChecking gcloud..." -ForegroundColor Yellow
gcloud --version

Write-Host "`nChecking Git..." -ForegroundColor Yellow
git --version

Write-Host "`n=== Prerequisites Check Complete ===" -ForegroundColor Green
Write-Host "If all commands succeeded, Jenkins agent is ready!" -ForegroundColor Green

## 3. Verify GAR Repository
Write-Host "`nVerifying Google Artifact Registry..." -ForegroundColor Yellow
gcloud artifacts repositories describe dbt-docker-repo --location=asia-south1

## 4. Test Docker can authenticate with GAR
Write-Host "`nTesting Docker authentication..." -ForegroundColor Yellow
docker pull asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest

Write-Host "`n=== Jenkins Environment Ready! ===" -ForegroundColor Green
Write-Host "Now configure Jenkins job as per JENKINS_SETUP_GUIDE.md" -ForegroundColor Cyan
