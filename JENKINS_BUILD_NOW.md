# Jenkins Pipeline Configuration - Step-by-Step

## ✅ Prerequisites Verified

- [x] Docker: v29.2.0 ✅
- [x] gcloud: v556.0.0 ✅
- [x] Git: v2.53.0 ✅
- [x] GAR Repository: dbt-docker-repo ✅
- [x] Docker Image: Already in GAR ✅

---

## 🚀 Jenkins is Open! Follow These Steps:

### Step 1: Add GCP Credentials to Jenkins

1. In Jenkins web UI, go to:
   ```
   Manage Jenkins → Credentials → System → Global credentials → Add Credentials
   ```

2. Fill in the form:
   - **Kind**: `Secret file`
   - **Scope**: `Global`
   - **File**: Click "Choose File" and select your GCP service account JSON key
   - **ID**: `gcp-service-account-key` ⚠️ **IMPORTANT: Must be exactly this**
   - **Description**: `GCP Service Account for BigQuery and GAR`

3. Click **Create**

---

### Step 2: Create Jenkins Pipeline Job

1. From Jenkins Dashboard, click **"New Item"**

2. Configure:
   - **Enter an item name**: `dbt-docker-build`
   - **Type**: Select **"Pipeline"**
   - Click **OK**

3. In the configuration page:

   **General Section:**
   - Description: `Build dbt Docker image and push to Google Artifact Registry`
   
   **Build Triggers** (Optional):
   - ☑ Poll SCM: `H/5 * * * *` (checks GitHub every 5 minutes)
   
   **Pipeline Section:**
   - **Definition**: Select `Pipeline script from SCM`
   - **SCM**: Select `Git`
   - **Repository URL**: 
     ```
     https://github.com/arunagcp24/python-hello-jenkins.git
     ```
   - **Credentials**: Leave as "none" (public repo)
   - **Branches to build**: `*/main`
   - **Script Path**: `Jenkinsfile` ⚠️ **Exactly as shown**
   
4. Click **Save**

---

### Step 3: Build the Docker Image

1. You'll be redirected to the job page
2. Click **"Build Now"** button on the left sidebar
3. You'll see a build starting (e.g., #1)
4. Click on the build number
5. Click **"Console Output"** to watch live logs

---

### Step 4: Monitor the Build

You should see these stages execute:

```
Stage 1: Checkout ✓
  - Cloning repository from GitHub
  
Stage 2: Setup GCP Authentication ✓
  - Activating service account
  - Setting GCP project
  
Stage 3: Configure Docker for GAR ✓
  - Configuring Docker to use GAR
  
Stage 4: Build Docker Image ✓
  - Building Docker image with dbt
  - Tagging as latest and build number
  
Stage 5: Test dbt Project ✓
  - Running dbt debug to verify configuration
  
Stage 6: Push to GAR ✓
  - Pushing image to Google Artifact Registry
  
Stage 7: Cleanup ✓
  - Removing local Docker images
  
SUCCESS: Pipeline completed!
```

---

### Expected Build Output (Success):

```
Pipeline completed successfully!
Docker image pushed to: asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:1
Done. PASS=1 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=1
Finished: SUCCESS
```

**Build Duration**: ~3-5 minutes

---

### Step 5: Verify the Built Image

After successful build, verify in terminal:

```powershell
# List images in GAR
gcloud artifacts docker images list asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader

# Pull the latest image
docker pull asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest

# Check local images
docker images | Select-String "dbt-account-loader"
```

---

## 🎯 What Jenkins Does:

```
GitHub Repository (Code Update)
         ↓
Jenkins Detects Change
         ↓
Clones Latest Code
         ↓
Authenticates with GCP
         ↓
Builds Docker Image
  - Installs Python 3.11
  - Installs dbt packages
  - Copies dbt project
  - Configures profiles
         ↓
Tests dbt Configuration
         ↓
Pushes to Google Artifact Registry
  - Tags with build number
  - Tags with 'latest'
         ↓
Docker Image Ready for Airflow!
```

---

## 🔄 Subsequent Builds:

After the first successful build:

1. **Manual Trigger**: Click "Build Now" anytime
2. **Automatic Trigger**: Jenkins will auto-build when you:
   - Push code to GitHub
   - Jenkins polls and detects changes

Each build creates a new image with:
- Tag: `latest` (always points to newest build)
- Tag: `<build-number>` (e.g., `1`, `2`, `3`...)

---

## 📊 View Build History:

In your Jenkins job, you'll see:

| Build | Status | Duration | Git Commit |
|-------|--------|----------|------------|
| #1    | ✅     | 4m 23s   | 55d9ac5    |
| #2    | ✅     | 3m 45s   | 9f86151    |

Click any build to see:
- Console output
- Changes (Git diff)
- Build artifacts
- Test results

---

## 🐛 Troubleshooting:

### Build Fails at "Setup GCP Authentication"
**Error**: `ERROR: Credential 'gcp-service-account-key' could not be found`  
**Fix**: Go back to Step 1, ensure credential ID is exactly `gcp-service-account-key`

### Build Fails at "Build Docker Image"
**Error**: `Cannot connect to Docker daemon`  
**Fix**: Ensure Docker Desktop is running on Jenkins agent

### Build Fails at "Push to GAR"
**Error**: `unauthorized: authentication required`  
**Fix**: 
```powershell
gcloud auth configure-docker asia-south1-docker.pkg.dev
```

### Build Fails at "Test dbt Project"
**Error**: `Not found: Dataset...`  
**Fix**: This is expected if service account doesn't have permissions. Pipeline will still push image successfully.

---

## ✅ Success Indicators:

You'll know it worked when you see:

1. ✅ Jenkins Console Output shows "SUCCESS"
2. ✅ GAR shows new image with build number tag
3. ✅ Image can be pulled: `docker pull asia-south1-docker...`
4. ✅ Image size is ~252 MB
5. ✅ Running the image executes dbt successfully

---

## 🎉 Next: Use Image in Airflow

Once Jenkins builds the image, your Airflow DAG can use it:

```python
image = "asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest"
```

The DAG will:
1. Pull latest image from GAR
2. Run dbt transformation
3. Load data to BigQuery

---

## 📞 Quick Reference:

**Jenkins URL**: http://localhost:8080  
**GitHub Repo**: https://github.com/arunagcp24/python-hello-jenkins.git  
**Jenkinsfile Path**: `Jenkinsfile` (Windows) or `Jenkinsfile.linux` (Linux)  
**Credential ID**: `gcp-service-account-key`  
**GAR Image**: `asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader`

---

**Now go to Jenkins and follow Steps 1-5 above! 🚀**
