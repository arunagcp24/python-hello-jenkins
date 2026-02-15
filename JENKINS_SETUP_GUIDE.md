# Jenkins Setup Guide - Build Docker Image via Jenkins

## Prerequisites Checklist

Before configuring Jenkins, ensure you have:

- [ ] Jenkins server running (access at http://localhost:8080 or your Jenkins URL)
- [ ] Docker installed on Jenkins agent/node
- [ ] gcloud CLI installed on Jenkins agent/node
- [ ] GCP service account JSON key file
- [ ] Git installed on Jenkins agent/node

---

## Step 1: Access Jenkins

Open your browser and navigate to:
```
http://localhost:8080
```
or your Jenkins server URL.

Login with your Jenkins credentials.

---

## Step 2: Install Required Jenkins Plugins

Go to: **Manage Jenkins** → **Plugins** → **Available plugins**

Install these plugins if not already installed:
- [x] Git Plugin
- [x] Pipeline Plugin
- [x] Docker Pipeline Plugin
- [x] Credentials Binding Plugin
- [x] Google Cloud Build Plugin (optional)

Click **Install** and restart Jenkins if needed.

---

## Step 3: Add GCP Service Account Credentials

### 3.1 Navigate to Credentials
**Manage Jenkins** → **Credentials** → **System** → **Global credentials** → **Add Credentials**

### 3.2 Configure Credential
- **Kind**: Secret file
- **File**: Upload your GCP service account JSON key file
- **ID**: `gcp-service-account-key` (must match Jenkinsfile)
- **Description**: GCP Service Account for BigQuery and GAR

Click **Create**

---

## Step 4: Create Jenkins Pipeline Job

### 4.1 Create New Item
1. From Jenkins dashboard, click **New Item**
2. Enter name: `dbt-docker-build-pipeline`
3. Select: **Pipeline**
4. Click **OK**

### 4.2 Configure General Settings
- **Description**: Build and push dbt Docker image to Google Artifact Registry
- Check: **GitHub project** (optional)
  - Project url: `https://github.com/arunagcp24/python-hello-jenkins/`

### 4.3 Configure Build Triggers (Optional)
- [ ] **GitHub hook trigger for GITScm polling** (for automatic builds on push)
- [ ] **Poll SCM**: `H/5 * * * *` (check every 5 minutes)

### 4.4 Configure Pipeline

**Pipeline Definition**: Pipeline script from SCM

**SCM**: Git

**Repository URL**: 
```
https://github.com/arunagcp24/python-hello-jenkins.git
```

**Credentials**: None (if public repo) or add GitHub credentials

**Branch Specifier**: 
```
*/main
```

**Script Path**: 
```
Jenkinsfile
```
(Use `Jenkinsfile.linux` if Jenkins runs on Linux)

Click **Save**

---

## Step 5: Verify Jenkins Environment

Before running the pipeline, verify the Jenkins agent has required tools:

### Create a test job to check:

```groovy
pipeline {
    agent any
    stages {
        stage('Check Environment') {
            steps {
                bat 'docker --version'
                bat 'gcloud --version'
                bat 'git --version'
            }
        }
    }
}
```

---

## Step 6: Run the Jenkins Pipeline

### 6.1 Manual Build
1. Go to your pipeline: `dbt-docker-build-pipeline`
2. Click **Build Now**
3. Click on the build number (e.g., #1) to see details
4. Click **Console Output** to watch the build logs

### 6.2 Pipeline Stages
The pipeline will execute these stages:

1. ✅ **Checkout** - Clone code from GitHub
2. ✅ **Setup GCP Authentication** - Activate service account
3. ✅ **Configure Docker for GAR** - Setup Docker auth
4. ✅ **Build Docker Image** - Build dbt container
5. ✅ **Test dbt Project** - Verify dbt works
6. ✅ **Push to GAR** - Upload image to Artifact Registry
7. ✅ **Cleanup** - Remove local images

### 6.3 Expected Output
```
SUCCESS
Total duration: ~5-10 minutes
Docker image pushed to: 
asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest
```

---

## Step 7: Verify Image in Google Artifact Registry

After successful build, verify the image:

```bash
gcloud artifacts docker images list \
  asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader
```

Should show:
- Image with latest tag
- Image with build number tag
- Created timestamp
- Image size

---

## Troubleshooting

### Issue: "Docker not found"
**Solution**: Install Docker on Jenkins agent
```bash
# Windows: Install Docker Desktop
# Linux: sudo apt-get install docker.io
```

### Issue: "gcloud not found"
**Solution**: Install Google Cloud SDK
```bash
# Download from: https://cloud.google.com/sdk/docs/install
```

### Issue: "Permission denied" on Docker
**Solution**: Add Jenkins user to docker group
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: "Credential not found: gcp-service-account-key"
**Solution**: Re-check Step 3 - ensure credential ID matches exactly

### Issue: "Unable to push to GAR"
**Solution**: 
1. Check service account has Artifact Registry Writer role
2. Verify GAR repository exists
3. Check gcloud auth is configured correctly

---

## Jenkins Pipeline Architecture

```
GitHub Repository
     ↓ (webhook/poll)
Jenkins Pipeline Triggered
     ↓
Checkout Code
     ↓
Authenticate with GCP
     ↓
Build Docker Image
     ↓
Test Image
     ↓
Push to Google Artifact Registry
     ↓
Image Available for Airflow
```

---

## Next Steps After Successful Build

1. ✅ Docker image is in GAR
2. ✅ Ready for Airflow to use
3. ✅ Can deploy to production

### Use the image:
```bash
docker pull asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest
```

### Run the image:
```bash
docker run --rm \
  asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest \
  dbt run --models account_info --project-dir /app/bq_analytics
```

---

## Automation Tips

### Enable Automatic Builds on Git Push

1. **In GitHub**:
   - Go to repository → Settings → Webhooks
   - Add webhook: `http://your-jenkins-url/github-webhook/`
   - Events: Just the push event

2. **In Jenkins**:
   - Enable "GitHub hook trigger for GITScm polling" in job config

Now every push to GitHub will automatically trigger Jenkins build!

---

## Review Jenkins Build History

Go to your pipeline job and you'll see:
- Build numbers
- Build status (Success/Failure)
- Build duration
- Git commit that triggered the build

Click on any build to see:
- Console output
- Changes (Git commits)
- Artifacts
- Test results

---

**Ready to build! Follow these steps to create your Docker image through Jenkins.**
