# Push Docker Image to Google Artifact Registry
# Run this script after Jenkins builds the image successfully

$PROJECT_ID = "project-51b9a3dd-ce80-4752-b31"
$GAR_LOCATION = "asia-south1"
$GAR_REPO = "dbt-docker-repo"
$IMAGE_NAME = "dbt-account-loader"

# Get the latest build number from Jenkins or use 'latest' tag
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Push Docker Image to GAR" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# List available images
Write-Host "Available local images:" -ForegroundColor Yellow
docker images | Select-String "$IMAGE_NAME"
Write-Host ""

# Prompt for build number or use latest
$buildNumber = Read-Host "Enter Jenkins build number (or press Enter to push 'latest' tag)"

if ([string]::IsNullOrWhiteSpace($buildNumber)) {
    $imageTag = "latest"
} else {
    $imageTag = $buildNumber
}

$fullImageName = "$GAR_LOCATION-docker.pkg.dev/$PROJECT_ID/$GAR_REPO/$IMAGE_NAME:$imageTag"

Write-Host ""
Write-Host "Pushing image: $fullImageName" -ForegroundColor Green
Write-Host ""

# Push the image
docker push $fullImageName

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "SUCCESS! Image pushed to GAR" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Image location:" -ForegroundColor Cyan
    Write-Host "$fullImageName" -ForegroundColor White
    Write-Host ""
    
    # Also push latest tag if a specific build number was pushed
    if ($imageTag -ne "latest") {
        Write-Host "Also pushing 'latest' tag..." -ForegroundColor Yellow
        $latestImage = "$GAR_LOCATION-docker.pkg.dev/$PROJECT_ID/$GAR_REPO/$IMAGE_NAME:latest"
        docker push $latestImage
    }
    
    Write-Host ""
    Write-Host "Verify in GAR:" -ForegroundColor Cyan
    Write-Host "gcloud artifacts docker images list $GAR_LOCATION-docker.pkg.dev/$PROJECT_ID/$GAR_REPO/$IMAGE_NAME" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Red
    Write-Host "FAILED to push image" -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure you are authenticated:" -ForegroundColor Yellow
    Write-Host "gcloud auth login" -ForegroundColor White
    Write-Host "gcloud auth application-default login" -ForegroundColor White
}
