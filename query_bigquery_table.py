#!/usr/bin/env python3
"""
Query BigQuery table: account_product_details
Project: project-51b9a3dd-ce80-4752-b31
Dataset: bigquery_dbt_project_bq_dbt_analytics
Table: account_product_details
"""

from google.cloud import bigquery
import pandas as pd

def query_account_product_details():
    """Query the BigQuery table and display results"""
    
    # Initialize BigQuery client
    client = bigquery.Client()
    
    # Define the query
    query = """
    SELECT *
    FROM `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project_bq_dbt_analytics.account_product_details`
    LIMIT 100
    """
    
    print("Querying BigQuery table...")
    print(f"Project: project-51b9a3dd-ce80-4752-b31")
    print(f"Dataset: bigquery_dbt_project_bq_dbt_analytics")
    print(f"Table: account_product_details")
    print("-" * 80)
    
    try:
        # Execute the query
        query_job = client.query(query)
        
        # Get results as a DataFrame
        df = query_job.to_dataframe()
        
        print(f"\nTotal rows fetched: {len(df)}")
        print("-" * 80)
        
        # Display table information
        print("\nColumn Names:")
        print(df.columns.tolist())
        print("-" * 80)
        
        # Display data types
        print("\nColumn Data Types:")
        print(df.dtypes)
        print("-" * 80)
        
        # Display first few rows
        print("\nFirst 10 rows:")
        print(df.head(10).to_string())
        print("-" * 80)
        
        # Display basic statistics for numerical columns
        if not df.select_dtypes(include=['number']).empty:
            print("\nNumeric Column Statistics:")
            print(df.describe())
            print("-" * 80)
        
        # Save to CSV for further analysis
        output_file = "account_product_details_output.csv"
        df.to_csv(output_file, index=False)
        print(f"\nData exported to: {output_file}")
        
        return df
        
    except Exception as e:
        print(f"\nError querying BigQuery: {str(e)}")
        print("\nPlease ensure:")
        print("1. You are authenticated with GCP (run: gcloud auth application-default login)")
        print("2. You have access to the BigQuery project and dataset")
        print("3. The table name is correct")
        return None

if __name__ == "__main__":
    query_account_product_details()
