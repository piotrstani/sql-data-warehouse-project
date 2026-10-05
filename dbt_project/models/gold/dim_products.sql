{{ config(
    schema='gold',
    materialized='view',
    unique_key='product_key'
) }}

WITH crm_prd_info AS (
    SELECT  *
    FROM {{ ref('crm_prd_info') }}
)
 ,erp_px_cat_g1v2 AS (
    SELECT  *
    FROM {{ ref('erp_px_cat_g1v2') }}
)

, dim_data AS (
select
	MD5(cpi.prd_key::text) AS product_key,
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
where cpi.prd_end_dt is null
and dbt_valid_to is null
)

SELECT * FROM dim_data dim
