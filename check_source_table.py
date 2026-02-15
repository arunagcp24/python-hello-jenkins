#!/usr/bin/env python3
"""
Check the structure of the source account table
"""

from google.cloud import bigquery

def check_source_table():
    """Check columns in source table"""
    
    client = bigquery.Client()
    
    query = """
    SELECT *
    FROM `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project.account`
    LIMIT 1
    """
    
    print("Checking source table structure...")
    print("Table: project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project.account")
    print("-" * 80)
    
    try:
        query_job = client.query(query)
        df = query_job.to_dataframe()
        
        print("\nColumn Names:")
        for col in df.columns:
            print(f"  - {col}")
        
        print("\nColumn Data Types:")
        print(df.dtypes)
        
        print("\nFirst Row:")
        print(df.head(1).to_string())
        
        return df.columns.tolist()
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        return None

if __name__ == "__main__":
    check_source_table()
