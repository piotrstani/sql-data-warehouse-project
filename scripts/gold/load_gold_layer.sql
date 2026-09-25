--------------------------------------------------------------CUSTOMER
--CRM is master 
create view gold.dim_customers as
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
from silver.crm_cust_info cci
left join silver.erp_cust_az12 eca 
	on cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela 
	on cci.cst_key = ela.cid 
--------------------------------------------------------------PRODUCT
