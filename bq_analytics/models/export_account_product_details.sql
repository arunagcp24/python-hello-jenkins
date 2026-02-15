-- Export account_product_details to see all columns
SELECT 
    account_id,
    account_number,
    account_type,
    balance,
    account_status,
    product_id,
    product_name,
    product_category,
    interest_rate,
    created_date,
    last_updated
FROM `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project_bq_dbt_analytics.account_product_details`
ORDER BY account_id
