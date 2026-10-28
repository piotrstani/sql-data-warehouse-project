{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='fail',
    unique_key='sls_ord_num',
    tags='fact'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('bronze', 'crm_sales_details') }}
),

transformed_data AS (
select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_dt::varchar !~ '\d{8}' then null
		else sls_order_dt::varchar::date end as sls_order_dt,
	case when sls_ship_dt::varchar !~ '\d{8}' then null
		else sls_ship_dt::varchar::date end as sls_ship_dt,
	case when sls_due_dt::varchar !~ '\d{8}' then null
		else sls_due_dt::varchar::date 	end as sls_due_dt,
	case when sls_sales <= 0 or sls_sales is null or sls_quantity * sls_price != sls_sales then sls_quantity * ABS(sls_price)
		else sls_sales end as sls_sales,
	sls_quantity,
	case when sls_price = 0 or sls_price is null then sls_sales / nullif(sls_quantity,0)
	    when sls_price < 0 then abs(sls_sales)
		else sls_price end as sls_price
    FROM source_data
)

SELECT * FROM transformed_data src
WHERE sls_order_dt is not null
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    {{ log('Loading ' ~ this ~ ' incrementally (start_date: ' ~ var("start_date") ~ ', end_date: ' ~ var("end_date") ~ ')', info=True) }}
    AND sls_order_dt >= '{{ var("start_date") }}'
    AND sls_order_dt < '{{ var("end_date") }}'
  {% else %}
    AND sls_order_dt > (SELECT coalesce(MAX(sls_order_dt), '1900-01-01') FROM {{ this }})
    {% if execute %}
        {{ log('Loading "DataWarehouse"."silver"."crm_sales_details" incrementally...', info=True) }}
    {% endif %}
  {% endif %}
{% endif %}