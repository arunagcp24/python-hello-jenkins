-- Load account data from source to target
-- Source: bigquery_dbt_project.account
-- Target: bq_dbt_analytics.account_info

{{
  config(
    materialized='table',
    schema='bq_dbt_analytics',
    alias='account_info'
  )
}}

SELECT 
    account_id,
    account_number,
    customer_id,
    account_type,
    currency_code,
    balance,
    credit_limit,
    status as account_status,
    created_at,
    updated_at,
    CURRENT_TIMESTAMP() as processed_timestamp
FROM `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project.account`
