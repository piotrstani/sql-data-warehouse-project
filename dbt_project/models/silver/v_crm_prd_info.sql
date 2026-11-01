{{ config(
    schema='silver',
    materialized='view',
    unique_key='prd_id'
) }}

WITH crm_prd_info AS (
    SELECT  *
    FROM {{ ref('crm_prd_info') }}
    )

, v_crm_prd_info AS (
    SELECT
    dbt_scd_id,
    dbt_valid_from::date AS start_dt,
    dbt_valid_to::date AS end_dt,
    dbt_updated_at,
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
    FROM crm_prd_info
    )

SELECT * FROM v_crm_prd_info view
