# Service Account Key Required

For the Docker container to work, you need to place your GCP service account key file here.

**IMPORTANT: Never commit this file to Git!**

## How to get the service account key:

1. Go to GCP Console: https://console.cloud.google.com
2. Navigate to: IAM & Admin → Service Accounts
3. Select or create a service account with BigQuery permissions
4. Click "Keys" → "Add Key" → "Create new key"
5. Choose JSON format
6. Save the downloaded file as: `service-account-key.json` in this directory

## Required Permissions:

The service account needs these roles:
- BigQuery Data Editor
- BigQuery Job User
- BigQuery Read Session User

## For Docker Build (Temporary):

For now, we'll build without the actual key file. The key should be mounted at runtime or added during deployment.
