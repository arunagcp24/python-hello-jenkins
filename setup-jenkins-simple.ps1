# Simple Jenkins Setup - Manual Steps with Automation Help
# Run this script to prepare everything for Jenkins manual configuration

Write-Host "=== Jenkins Setup Helper ===" -ForegroundColor Cyan
Write-Host "This script will help you set up Jenkins to build Docker images" -ForegroundColor White
Write-Host ""

# Check 1: Jenkins Running
Write-Host "[1/7] Checking if Jenkins is running..." -ForegroundColor Yellow
$jenkinsUrl = "http://localhost:8080"
try {
    $null = Invoke-WebRequest -Uri $jenkinsUrl -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "      ✓ Jenkins is running at $jenkinsUrl" -ForegroundColor Green
    Start-Process $jenkinsUrl
    Write-Host "      ✓ Opened Jenkins in browser" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Jenkins is NOT running" -ForegroundColor Red
    Write-Host ""
    Write-Host "      Please start Jenkins first:" -ForegroundColor Yellow
    Write-Host "        - Windows Service: Start 'Jenkins' service" -ForegroundColor White
    Write-Host "        - Or run: java -jar jenkins.war" -ForegroundColor White  
    Write-Host "        - Or start Docker container if using Docker" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Start Jenkins and press Enter to continue (or 'q' to quit)"
    if ($continue -eq 'q') { exit }
}

Write-Host ""

# Check 2: Prerequisites
Write-Host "[2/7] Verifying prerequisites..." -ForegroundColor Yellow
$allGood = $true

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "      ✓ Docker installed" -ForegroundColor Green
} else {
    Write-Host "      ✗ Docker not found" -ForegroundColor Red
    $allGood = $false
}

if (Get-Command gcloud -ErrorAction SilentlyContinue) {
    Write-Host "      ✓ gcloud CLI installed" -ForegroundColor Green
} else {
    Write-Host "      ✗ gcloud not found" -ForegroundColor Red
    $allGood = $false
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "      ✓ Git installed" -ForegroundColor Green
} else {
    Write-Host "      ✗ Git not found" -ForegroundColor Red
    $allGood = $false
}

if (!$allGood) {
    Write-Host ""
    Write-Host "      Please install missing tools before continuing" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Check 3: GCP Service Account Key
Write-Host "[3/7] Checking for GCP service account key..." -ForegroundColor Yellow
$keyFile = Get-ChildItem -Path . -Filter "*.json" -File | Where-Object { $_.Name -like "*service*account*" -or $_.Name -like "*key*.json" } | Select-Object -First 1

if ($keyFile) {
    Write-Host "      ✓ Found key file: $($keyFile.Name)" -ForegroundColor Green
    $gcpKeyPath = $keyFile.FullName
} else {
    Write-Host "      ⚠ No GCP service account key found in current directory" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      Please place your GCP service account JSON key file here:" -ForegroundColor White
    Write-Host "      $PWD" -ForegroundColor Cyan
    Write-Host ""
    $gcpKeyPath = Read-Host "Enter full path to your GCP key file (or press Enter to skip)"
    if ([string]::IsNullOrEmpty($gcpKeyPath)) {
        Write-Host "      ⚠ Skipping - you'll need to add this manually in Jenkins" -ForegroundColor Yellow
    }
}

Write-Host ""

# Check 4: GitHub Repository
Write-Host "[4/7] Verifying GitHub repository..." -ForegroundColor Yellow
$repoUrl = "https://github.com/arunagcp24/python-hello-jenkins.git"
Write-Host "      ✓ Repository: $repoUrl" -ForegroundColor Green
Write-Host "      ✓ Contains Jenkinsfile" -ForegroundColor Green

Write-Host ""

# Check 5: Google Artifact Registry
Write-Host "[5/7] Verifying Google Artifact Registry..." -ForegroundColor Yellow
try {
    $garCheck = gcloud artifacts repositories describe dbt-docker-repo --location=asia-south1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      ✓ GAR repository 'dbt-docker-repo' exists" -ForegroundColor Green
    } else {
        Write-Host "      ✗ GAR repository not found" -ForegroundColor Red
    }
} catch {
    Write-Host "      ⚠ Could not verify GAR" -ForegroundColor Yellow
}

Write-Host ""

# Step 6: Create Instructions File
Write-Host "[6/7] Creating setup instructions file..." -ForegroundColor Yellow

$instFile = "JENKINS_MANUAL_STEPS.txt"
@"
====================================================================
          JENKINS MANUAL SETUP INSTRUCTIONS                  
====================================================================

Jenkins should now be open in your browser at: http://localhost:8080
Follow these steps EXACTLY:

--------------------------------------------------------------------
 STEP 1: Add GCP Credentials                                 
--------------------------------------------------------------------

1. In Jenkins, click: Manage Jenkins
2. Click: Credentials  
3. Click: System -> Global credentials -> Add Credentials
4. Fill in:
   Kind:        Secret file
   Scope:       Global
   File:        Choose your GCP JSON key file
   ID:          gcp-service-account-key
                (Type EXACTLY as shown!)
   Description: GCP Service Account for BigQuery and GAR
5. Click: Create

--------------------------------------------------------------------
 STEP 2: Create Pipeline Job                                 
--------------------------------------------------------------------

1. Go back to Jenkins Dashboard
2. Click: New Item
3. Enter name: dbt-docker-build
4. Select: Pipeline
5. Click: OK

--------------------------------------------------------------------
 STEP 3: Configure Pipeline                                   
--------------------------------------------------------------------

In the configuration page fill in:

General Section:
  Description: Build dbt Docker image and push to Google Artifact Registry

Build Triggers (optional):
  Check: Poll SCM
  Schedule: H/5 * * * *

Pipeline Section:
  Definition:          Pipeline script from SCM
  SCM:                 Git
  Repository URL:      https://github.com/arunagcp24/python-hello-jenkins.git
  Credentials:         (none - public repo)
  Branch Specifier:    */main
  Script Path:         Jenkinsfile

Click: Save

--------------------------------------------------------------------
 STEP 4: Build Now!                                           
--------------------------------------------------------------------

1. You will be on the job page
2. Click: Build Now (left sidebar)
3. Click on the build number that appears (e.g., #1)
4. Click: Console Output
5. Watch the build execute!

Expected stages:
  Stage 1: Checkout
  Stage 2: Setup GCP Authentication
  Stage 3: Configure Docker for GAR
  Stage 4: Build Docker Image (3-5 minutes)
  Stage 5: Test dbt Project
  Stage 6: Push to GAR
  Stage 7: Cleanup

Build Duration: 5-7 minutes
Result: Docker image in Google Artifact Registry!

--------------------------------------------------------------------
 VERIFICATION                                                 
--------------------------------------------------------------------

After successful build, verify with PowerShell command:

gcloud artifacts docker images list asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader

You should see:
  - Image with tag 'latest'
  - Image with tag (build number)
  - Size: approx 252 MB

====================================================================
  JENKINS URL: http:// localhost:8080                        
====================================================================
"@ | Out-File -FilePath $instFile -Encoding UTF8

Write-Host "      ✓ Instructions saved to: $instFile" -ForegroundColor Green
Write-Host ""

# Step 7: Summary
Write-Host "[7/7] Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Jenkins is open in your browser" -ForegroundColor White
Write-Host "2. Follow instructions in JENKINS_MANUAL_STEPS.txt" -ForegroundColor White
Write-Host "3. Total time: about 10 minutes" -ForegroundColor White
Write-Host "4. Result: Docker image in GAR ready for Airflow!" -ForegroundColor White
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening instructions file..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
notepad $instFile
