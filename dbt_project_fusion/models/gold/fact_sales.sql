{{ config(
    schema='gold',
    materialized='view',
    unique_key='order_number'
) }}

WITH crm_sales_details AS (
    SELECT  *
    FROM {{ ref('crm_sales_details') }}
)
 ,dim_products AS (
    SELECT  *
    FROM {{ ref('dim_products') }}
)

 ,dim_customers AS (
    SELECT  *
    FROM {{ ref('dim_customers') }}
)

, fact_data AS (
select
	csd.sls_ord_num as order_number,
	dp.product_key as product_key,
	dc.customer_key as customer_key,
	csd.sls_order_dt as order_date,
	csd.sls_ship_dt as shipping_date,
	csd.sls_due_dt as due_dt,
	csd.sls_sales as sales_amount,
	csd.sls_quantity as quantity,
	csd.sls_price as price
from crm_sales_details as csd
left join dim_products as dp
	on csd.sls_prd_key = dp.product_number
left join dim_customers dc
	on csd.sls_cust_id = dc.customer_id
)

SELECT * FROM fact_data fact

