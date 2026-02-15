# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy dbt project
COPY bq_analytics/ /app/bq_analytics/

# Copy profiles directory
RUN mkdir -p /root/.dbt
COPY profiles.yml /root/.dbt/profiles.yml

# Set environment variables
ENV DBT_PROJECT_DIR=/app/bq_analytics
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json

# Default command
CMD ["dbt", "run", "--project-dir", "/app/bq_analytics"]
