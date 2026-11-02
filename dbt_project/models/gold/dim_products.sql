{{ config(
    schema='gold',
    materialized='view',
    unique_key='product_key'
) }}

{# Pobranie zmiennej z CLI lub ustawienie dzisiejszej daty jako domyślnej #}
{% set v_due_dt_val = var('v_due_dt', run_started_at.strftime('%Y-%m-%d')) %}

WITH crm_prd_info AS (
    SELECT  *
    FROM {{ ref('v_crm_prd_info') }}
)
 ,erp_px_cat_g1v2 AS (
    SELECT  *
    FROM {{ ref('erp_px_cat_g1v2') }}
)

, dim_data AS (
select
    '{{ v_due_dt_val }}'::date as due_dt,
	MD5(cpi.prd_id::text) AS product_key,
	cpi.prd_id as product_id,
	cpi.prd_key as product_number,
	cpi.prd_nm as product_name,
	cpi.cat_id as category_id,
	epcgv.cat as category,
	epcgv.subcat as subcategory,
	epcgv.maintenance as maintenance,
	cpi.prd_cost as cost,
	cpi.prd_line as product_line,
	cpi.prd_start_dt as start_date
from crm_prd_info as cpi
left join erp_px_cat_g1v2 epcgv
	on cpi.cat_id=epcgv.id
where '{{ v_due_dt_val }}'::date >= cpi.start_dt
  and ('{{ v_due_dt_val }}'::date <= cpi.end_dt or cpi.end_dt is null)
)

SELECT * FROM dim_data dim

{# dbt build -s dim_products --vars '{"v_due_dt": "2026-10-29"}' #}
