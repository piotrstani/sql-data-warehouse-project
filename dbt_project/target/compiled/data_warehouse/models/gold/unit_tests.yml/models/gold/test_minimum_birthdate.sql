

WITH  __dbt__cte__crm_cust_info as (

-- Fixture for crm_cust_info
select cast(null as integer) as "cst_id", 
    
    cast('1' as character varying)
 as "cst_key", cast(null as text) as "cst_firstname", cast(null as text) as "cst_lastname", cast(null as text) as "cst_marital_status", 
    
    cast('Male' as text)
 as "cst_gndr", cast(null as date) as "cst_create_date"
union all
select cast(null as integer) as "cst_id", 
    
    cast('2' as character varying)
 as "cst_key", cast(null as text) as "cst_firstname", cast(null as text) as "cst_lastname", cast(null as text) as "cst_marital_status", 
    
    cast('n/a' as text)
 as "cst_gndr", cast(null as date) as "cst_create_date"
),  __dbt__cte__erp_cust_az12 as (

-- Fixture for erp_cust_az12
select 
    
    cast('1' as character varying)
 as "cid", cast(null as date) as "bdate", 
    
    cast('n/a' as text)
 as "gen"
union all
select 
    
    cast('2' as character varying)
 as "cid", cast(null as date) as "bdate", 
    
    cast('Female' as text)
 as "gen"
),  __dbt__cte__erp_loc_a101 as (

-- Fixture for erp_loc_a101
select 
    
    cast('1' as text)
 as "cid", 
    
    cast('n/a' as text)
 as "cntry"
union all
select 
    
    cast('2' as text)
 as "cid", 
    
    cast('n/a' as text)
 as "cntry"
), crm_cust_info AS (
    SELECT  *
    FROM __dbt__cte__crm_cust_info
)
 ,erp_cust_az12 AS (
    SELECT  *
    FROM __dbt__cte__erp_cust_az12
)

 ,erp_loc_a101 AS (
    SELECT  *
    FROM __dbt__cte__erp_loc_a101
)

, dim_data AS (
select
	MD5(cci.cst_id::text) AS customer_key,
	cci.cst_id as customer_id,
	cci.cst_key as customer_number,
	cci.cst_firstname as first_name,
	cci.cst_lastname as last_name,
	cci.cst_marital_status as martial_status,
	case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen, 'n/a') end as gender,
	eca.bdate as birthdate,
	ela.cntry as country,
	cci.cst_create_date as create_date
from crm_cust_info as cci
left join erp_cust_az12 as eca
	on cci.cst_key = eca.cid
left join erp_loc_a101 ela
	on cci.cst_key = ela.cid
)

SELECT * FROM dim_data dim