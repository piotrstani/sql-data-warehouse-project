
  create view "DataWarehouse"."silver"."dim_customers__dbt_tmp"
    
    
  as (
    

WITH crm_cust_info AS (
    SELECT  *
    FROM "DataWarehouse"."silver"."crm_cust_info"
)
 ,erp_cust_az12 AS (
    SELECT  *
    FROM "DataWarehouse"."silver"."erp_cust_az12"
)

 ,erp_loc_a101 AS (
    SELECT  *
    FROM "DataWarehouse"."silver"."erp_loc_a101"
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
  );