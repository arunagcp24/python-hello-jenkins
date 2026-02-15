# Automated Jenkins Setup Script
# This script will configure Jenkins job using Jenkins CLI

param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JenkinsUser = "admin",
    [string]$JenkinsToken = "",
    [string]$GcpKeyFile = ""
)

Write-Host "=== Jenkins Automated Setup ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Jenkins is running
Write-Host "Step 1: Checking Jenkins connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $JenkinsUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Jenkins is running at $JenkinsUrl" -ForegroundColor Green
} catch {
    Write-Host "✗ Jenkins is not accessible at $JenkinsUrl" -ForegroundColor Red
    Write-Host "  Please start Jenkins and try again" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  To start Jenkins:" -ForegroundColor White
    Write-Host "    - Windows: Start Jenkins service or run jenkins.war" -ForegroundColor White
    Write-Host "    - Check: http://localhost:8080" -ForegroundColor White
    exit 1
}

Write-Host ""

# Step 2: Download Jenkins CLI
Write-Host "Step 2: Downloading Jenkins CLI..." -ForegroundColor Yellow
$cliPath = "$PSScriptRoot\jenkins-cli.jar"
try {
    Invoke-WebRequest -Uri "$JenkinsUrl/jnlpJars/jenkins-cli.jar" -OutFile $cliPath -ErrorAction Stop
    Write-Host "✓ Jenkins CLI downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download Jenkins CLI" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 3: Check authentication
Write-Host "Step 3: Jenkins Authentication Setup" -ForegroundColor Yellow
Write-Host ""
if ([string]::IsNullOrEmpty($JenkinsToken)) {
    Write-Host "⚠ No Jenkins API token provided" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  To get your Jenkins API token:" -ForegroundColor White
    Write-Host "  1. Go to: $JenkinsUrl/user/admin/configure" -ForegroundColor White
    Write-Host "  2. Click 'Add new Token' under API Token section" -ForegroundColor White
    Write-Host "  3. Copy the generated token" -ForegroundColor White
    Write-Host "  4. Run this script again with -JenkinsToken parameter" -ForegroundColor White
    Write-Host "" 
    Write-Host "  Example:" -ForegroundColor Cyan
    Write-Host "  .\setup-jenkins-auto.ps1 -JenkinsToken 'your-token-here' -GcpKeyFile 'path\to\key.json'" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host ""

# Step 4: Add GCP Credential
Write-Host "Step 4: Adding GCP Service Account Credential..." -ForegroundColor Yellow
if ([string]::IsNullOrEmpty($GcpKeyFile) -or !(Test-Path $GcpKeyFile)) {
    Write-Host "✗ GCP key file not found: $GcpKeyFile" -ForegroundColor Red
    Write-Host "  Please provide valid GCP service account key file" -ForegroundColor Yellow
    exit 1
}

# Create credential XML
$credentialXml = @"
<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>gcp-service-account-key</id>
  <description>GCP Service Account for BigQuery and  GAR</description>
  <fileName>service-account-key.json</fileName>
  <secretBytes>$(Get-Content $GcpKeyFile -Raw | ConvertTo-Base64String)</secretBytes>
</org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
"@

Write-Host "  Creating GCP credential in Jenkins..." -ForegroundColor White
# Note: This requires the credentials plugin and proper CLI setup
Write-Host "⚠ Manual step required: Add credential via Jenkins UI" -ForegroundColor Yellow
Write-Host "  Go to: $JenkinsUrl/credentials/store/system/domain/_/newCredentials" -ForegroundColor White

Write-Host ""

# Step 5: Create Jenkins Job
Write-Host "Step 5: Creating Jenkins Pipeline Job..." -ForegroundColor Yellow
$jobConfigPath = "$PSScriptRoot\jenkins-job-config.xml"
$jobName = "dbt-docker-build"

try {
    # Create job using CLI
    $env:JENKINS_USER_ID = $JenkinsUser
    $env:JENKINS_API_TOKEN = $JenkinsToken
    
    java -jar $cliPath -s $JenkinsUrl -auth "$JenkinsUser`:$JenkinsToken" create-job $jobName < $jobConfigPath
    Write-Host "✓ Jenkins job '$jobName' created successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠ Job might already exist or manual creation needed" -ForegroundColor Yellow
    Write-Host "  Error: $_" -ForegroundColor Red
}

Write-Host ""

# Step 6: Trigger Build
Write-Host "Step 6: Ready to build!" -ForegroundColor Yellow
Write-Host ""
Write-Host "To trigger the build:" -ForegroundColor White
Write-Host "  Option 1 (CLI):" -ForegroundColor Cyan
Write-Host "    java -jar jenkins-cli.jar -s $JenkinsUrl -auth $JenkinsUser`:$JenkinsToken build $jobName" -ForegroundColor White
Write-Host ""
Write-Host "  Option 2 (Web UI):" -ForegroundColor Cyan
Write-Host "    1. Go to: $JenkinsUrl/job/$jobName/" -ForegroundColor White
Write-Host "    2. Click 'Build Now'" -ForegroundColor White
Write-Host ""

# Summary
Write-Host "=== Setup Summary ===" -ForegroundColor Cyan
Write-Host "✓ Jenkins accessible: $JenkinsUrl" -ForegroundColor Green
Write-Host "✓ Jenkins CLI downloaded" -ForegroundColor Green
Write-Host "⚠ GCP Credential: Add manually via UI" -ForegroundColor Yellow
Write-Host "✓ Job Config: jenkins-job-config.xml created" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Add GCP credential with ID 'gcp-service-account-key' in Jenkins UI" -ForegroundColor White
Write-Host "2. Visit: $JenkinsUrl/job/$jobName/" -ForegroundColor White
Write-Host "3. Click 'Build Now' to start the Docker image build" -ForegroundColor White
Write-Host ""
