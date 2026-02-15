# dbt Account Loader - Docker Pipeline

A complete data pipeline that loads account data from BigQuery source to target table using dbt, containerized with Docker, automated with Jenkins CI/CD, and orchestrated with Airflow.

## 🎯 Project Overview

**Source Table**: `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project.account`  
**Target Table**: `project-51b9a3dd-ce80-4752-b31.bq_dbt_analytics.account_info`

### Pipeline Flow
```
Source Data (BigQuery) 
    ↓
dbt Transformation
    ↓
Docker Container
    ↓
Jenkins CI/CD → Google Artifact Registry
    ↓
Airflow DAG Orchestration
    ↓
Target Table (BigQuery)
```

## 📁 Project Structure

```
GCP_GDW_Bigquery/
├── bq_analytics/              # dbt project
│   ├── models/
│   │   ├── account_info.sql   # Main dbt model
│   │   └── account_info.md    # Model documentation
│   ├── dbt_project.yml        # dbt configuration
│   └── ...
├── dags/                      # Airflow DAGs
│   ├── dbt_account_loader_dag.py      # Docker operator DAG
│   └── dbt_account_loader_gke_dag.py  # GKE operator DAG
├── Dockerfile                 # Docker image definition
├── Jenkinsfile               # Jenkins pipeline (Windows)
├── Jenkinsfile.linux         # Jenkins pipeline (Linux)
├── requirements.txt          # Python dependencies
├── profiles.yml              # dbt profiles for Docker
├── build-and-test.sh         # Local test script (Linux)
├── build-and-test.bat        # Local test script (Windows)
├── .gitignore
├── .dockerignore
└── README.md
```

## 🚀 Setup Instructions

### Prerequisites

1. **Google Cloud Platform**
   - GCP Project: `project-51b9a3dd-ce80-4752-b31`
   - BigQuery API enabled
   - Artifact Registry API enabled
   - Service Account with necessary permissions

2. **Local Tools**
   - Docker installed
   - gcloud CLI installed and configured
   - Git installed
   - Jenkins server
   - Airflow environment

3. **Credentials**
   - GCP Service Account JSON key file

### Step 1: Setup Google Artifact Registry

```bash
# Create Artifact Registry repository
gcloud artifacts repositories create dbt-docker-repo \
    --repository-format=docker \
    --location=asia-south1 \
    --description="dbt Docker images repository"

# Configure Docker authentication
gcloud auth configure-docker asia-south1-docker.pkg.dev
```

### Step 2: Clone and Configure

```bash
# Clone the repository
git clone https://github.com/arunagcp24/dbt-account-loader.git
cd dbt-account-loader

# Place your GCP service account key
# (Never commit this file!)
cp /path/to/your/service-account-key.json ./service-account-key.json
```

### Step 3: Test Locally

**On Windows:**
```bash
build-and-test.bat
```

**On Linux/Mac:**
```bash
chmod +x build-and-test.sh
./build-and-test.sh
```

### Step 4: Setup Jenkins

#### 4.1 Create Jenkins Credentials
- Go to Jenkins → Manage Jenkins → Credentials
- Add credential:
  - Kind: Secret file
  - ID: `gcp-service-account-key`
  - File: Upload your GCP service account JSON key

#### 4.2 Create Jenkins Pipeline Job
1. Click **"New Item"**
2. Name: `dbt-account-loader-pipeline`
3. Type: **Pipeline**
4. Pipeline Configuration:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/arunagcp24/<your-repo>.git`
   - Script Path: 
     - Windows: `Jenkinsfile`
     - Linux: `Jenkinsfile.linux`
5. Save

#### 4.3 Run Jenkins Pipeline
- Click **Build Now**
- Monitor the pipeline stages:
  - ✅ Checkout
  - ✅ Setup GCP Authentication
  - ✅ Configure Docker for GAR
  - ✅ Build Docker Image
  - ✅ Test dbt Project
  - ✅ Push to GAR
  - ✅ Cleanup

### Step 5: Setup Airflow

#### 5.1 Copy DAG Files
```bash
# Copy DAG to Airflow dags folder
cp dags/dbt_account_loader_dag.py $AIRFLOW_HOME/dags/
```

#### 5.2 Configure Airflow Variables
In Airflow UI:
- Admin → Variables
- Add:
  - `gcp_project_id`: `project-51b9a3dd-ce80-4752-b31`
  - `gar_location`: `asia-south1`

#### 5.3 Configure Airflow Connection
- Admin → Connections
- Add Connection:
  - Conn Id: `google_cloud_default`
  - Conn Type: `Google Cloud`
  - Keyfile JSON: Paste your service account key

#### 5.4 Enable and Run DAG
1. Find `dbt_account_loader_docker` in Airflow UI
2. Toggle to **ON**
3. Click **Trigger DAG**
4. Monitor execution

## 🐳 Docker Image Details

### Image Location
```
asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest
```

### Image Contents
- Python 3.11
- dbt-core 1.11.5
- dbt-bigquery 1.11.0
- Complete dbt project
- Configured profiles.yml

### Run Docker Container Manually
```bash
# Pull the image
docker pull asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest

# Run dbt model
docker run --rm \
  asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest \
  dbt run --models account_info --project-dir /app/bq_analytics
```

## 📊 dbt Model Details

### Model: account_info

**Materialization**: Table  
**Schema**: bq_dbt_analytics

**Transformations**:
- Selects all columns from source table
- Adds `processed_timestamp` column
- Creates table in target dataset

**Run Model Locally** (with dbt installed):
```bash
cd bq_analytics
dbt run --models account_info
```

**View Compiled SQL**:
```bash
dbt compile --models account_info
cat target/compiled/bq_analytics/models/account_info.sql
```

## 🔄 CI/CD Pipeline Workflow

1. **Developer pushes code to GitHub**
2. **Jenkins detects changes** (webhook/polling)
3. **Jenkins Pipeline executes**:
   - Authenticates with GCP
   - Builds Docker image
   - Tests dbt configuration
   - Pushes image to Google Artifact Registry
4. **Airflow DAG** (scheduled or manual):
   - Pulls latest Docker image from GAR
   - Runs dbt model in container
   - Executes tests
   - Logs results

## 📅 Airflow Schedule

- **Default Schedule**: Daily at 2:00 AM UTC
- **Modify Schedule**: Edit `schedule_interval` in DAG file

```python
schedule_interval='0 2 * * *'  # Cron expression
```

## 🔍 Monitoring & Troubleshooting

### Check dbt Logs
```bash
# In Jenkins console output or Airflow task logs
```

### Debug Docker Container
```bash
docker run -it --rm \
  asia-south1-docker.pkg.dev/project-51b9a3dd-ce80-4752-b31/dbt-docker-repo/dbt-account-loader:latest \
  /bin/bash
```

### Check BigQuery Target Table
```sql
SELECT *
FROM `project-51b9a3dd-ce80-4752-b31.bq_dbt_analytics.account_info`
ORDER BY processed_timestamp DESC
LIMIT 10;
```

### Common Issues

**Issue**: Docker image fails to build  
**Solution**: Check Dockerfile syntax and ensure all files are present

**Issue**: dbt can't connect to BigQuery  
**Solution**: Verify service account key and permissions

**Issue**: Jenkins can't push to GAR  
**Solution**: Check GCP authentication and GAR permissions

## 🔐 Security Best Practices

1. **Never commit credentials** to Git
2. **Use Jenkins credentials manager** for sensitive data
3. **Rotate service account keys** regularly
4. **Limit service account permissions** to minimum required
5. **Use secret management** (Google Secret Manager, HashiCorp Vault)

## 📈 Future Enhancements

- [ ] Add data quality tests in dbt
- [ ] Implement incremental loading
- [ ] Add Slack/Email notifications
- [ ] Create data lineage documentation
- [ ] Add monitoring dashboards
- [ ] Implement blue-green deployments
- [ ] Add automated rollback mechanism

## 👥 Team & Support

- **Owner**: Data Engineering Team
- **Maintainer**: @arunagcp24
- **Support**: Create GitHub issues

## 📄 License

MIT License

---

**Last Updated**: February 15, 2026
