-- Query account_product_details table
-- This model selects all data from the account_product_details table

{{
  config(
    materialized='view'
  )
}}

SELECT *
FROM `project-51b9a3dd-ce80-4752-b31.bigquery_dbt_project_bq_dbt_analytics.account_product_details`
