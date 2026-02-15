# dbt Model: account_info

## Description
This model loads account data from the source table and creates a target table with processing timestamp.

## Source
- **Table**: `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project.account`

## Target
- **Table**: `project-51b9a3dd-ce80-4752-b31.bq_dbt_analytics.account_info`

## Columns
- account_id
- account_number
- account_type
- balance
- account_status
- processed_timestamp (added during transformation)

## Materialization
- Type: table
- Schema: bq_dbt_analytics
