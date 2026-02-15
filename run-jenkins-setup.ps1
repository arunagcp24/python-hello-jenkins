# Simple Jenkins Setup - Version 2
Write-Host "=== Jenkins Setup Helper ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: Prerequisites
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow
Write-Host "      Docker: " -NoNewline
docker --version
Write-Host "      gcloud: " -NoNewline  
gcloud --version | Select-Object -First 1
Write-Host "      Git: " -NoNewline
git --version
Write-Host ""

# Check 2: GAR
Write-Host "[2/5] Verifying Google Artifact Registry..." -ForegroundColor Yellow
$garCheck = gcloud artifacts repositories describe dbt-docker-repo --location=asia-south1 --format='value(name)' 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "      ✓ GAR repository exists" -ForegroundColor Green
} else {
    Write-Host "      ✗ GAR repository not found" -ForegroundColor Red
}
Write-Host ""

# Check 3: Jenkins
Write-Host "[3/5] Opening Jenkins..." -ForegroundColor Yellow
Start-Process "http://localhost:8080"
Write-Host "      ✓ Jenkins opened in browser" -ForegroundColor Green
Write-Host ""

# Check 4: Instructions
Write-Host "[4/5] Opening instructions..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
notepad "JENKINS_MANUAL_STEPS.txt"
Write-Host "      ✓ Instructions file opened" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "[5/5] Ready!" -ForegroundColor Green
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "FOLLOW THE INSTRUCTIONS IN THE TEXT FILE" -ForegroundColor Yellow
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Add GCP credential in Jenkins" -ForegroundColor White
Write-Host "  2. Create pipeline job" -ForegroundColor White
Write-Host "  3. Configure with GitHub repo" -ForegroundColor White
Write-Host "  4. Click Build Now" -ForegroundColor White
Write-Host "  5. Wait 5-7 minutes for build to complete" -ForegroundColor White
Write-Host ""
Write-Host "Result: Docker image in GAR ready for Airflow" -ForegroundColor Green
Write-Host ""
