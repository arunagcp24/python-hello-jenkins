"""
Airflow DAG to run dbt account loader in Docker container
Pulls Docker image from Google Artifact Registry and executes dbt run
"""

from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.providers.google.cloud.operators.kubernetes_engine import GKEStartPodOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

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
    dag_id='dbt_account_loader_docker',
    default_args=default_args,
    description='Load account data from source to target using dbt in Docker',
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    start_date=days_ago(1),
    catchup=False,
    tags=['dbt', 'bigquery', 'docker', 'etl'],
)

# Environment variables
PROJECT_ID = 'project-51b9a3dd-ce80-4752-b31'
GAR_LOCATION = 'asia-south1'
GAR_REPO = 'dbt-docker-repo'
IMAGE_NAME = 'dbt-account-loader'
DOCKER_IMAGE = f'{GAR_LOCATION}-docker.pkg.dev/{PROJECT_ID}/{GAR_REPO}/{IMAGE_NAME}:latest'

# Task 1: Run dbt model in Docker container
run_dbt_model = DockerOperator(
    task_id='run_dbt_account_loader',
    image=DOCKER_IMAGE,
    api_version='auto',
    auto_remove=True,
    command='dbt run --models account_info --project-dir /app/bq_analytics',
    docker_url='unix://var/run/docker.sock',
    network_mode='bridge',
    mount_tmp_dir=False,
    environment={
        'GOOGLE_APPLICATION_CREDENTIALS': '/app/service-account-key.json',
    },
    dag=dag,
)

# Task 2: Run dbt tests
run_dbt_tests = DockerOperator(
    task_id='run_dbt_tests',
    image=DOCKER_IMAGE,
    api_version='auto',
    auto_remove=True,
    command='dbt test --models account_info --project-dir /app/bq_analytics',
    docker_url='unix://var/run/docker.sock',
    network_mode='bridge',
    mount_tmp_dir=False,
    environment={
        'GOOGLE_APPLICATION_CREDENTIALS': '/app/service-account-key.json',
    },
    dag=dag,
)

# Set task dependencies
run_dbt_model >> run_dbt_tests
