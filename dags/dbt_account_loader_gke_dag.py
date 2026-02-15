"""
Alternative Airflow DAG using GKE Pod Operator
For running dbt job in Kubernetes/GKE environment
"""

from airflow import DAG
from airflow.providers.google.cloud.operators.kubernetes_engine import GKEStartPodOperator
from airflow.utils.dates import days_ago
from datetime import timedelta
from kubernetes.client import models as k8s

# Default arguments
default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'email': ['your-email@example.com'],
}

# DAG definition
dag = DAG(
    dag_id='dbt_account_loader_gke',
    default_args=default_args,
    description='Load account data using dbt in GKE Pod',
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    start_date=days_ago(1),
    catchup=False,
    tags=['dbt', 'bigquery', 'gke', 'kubernetes', 'etl'],
)

# Environment variables
PROJECT_ID = 'project-51b9a3dd-ce80-4752-b31'
GAR_LOCATION = 'asia-south1'
GAR_REPO = 'dbt-docker-repo'
IMAGE_NAME = 'dbt-account-loader'
DOCKER_IMAGE = f'{GAR_LOCATION}-docker.pkg.dev/{PROJECT_ID}/{GAR_REPO}/{IMAGE_NAME}:latest'
GKE_CLUSTER_NAME = 'your-gke-cluster'
GKE_ZONE = 'asia-south1-a'

# Task: Run dbt model in GKE Pod
run_dbt_in_gke = GKEStartPodOperator(
    task_id='run_dbt_account_loader_gke',
    project_id=PROJECT_ID,
    location=GKE_ZONE,
    cluster_name=GKE_CLUSTER_NAME,
    namespace='default',
    name='dbt-account-loader-pod',
    image=DOCKER_IMAGE,
    cmds=['dbt'],
    arguments=['run', '--models', 'account_info', '--project-dir', '/app/bq_analytics'],
    env_vars={
        'GOOGLE_APPLICATION_CREDENTIALS': '/app/service-account-key.json',
    },
    get_logs=True,
    is_delete_operator_pod=True,
    startup_timeout_seconds=600,
    dag=dag,
)

run_dbt_in_gke
