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
from silver.crm_cust_info as cci
left join silver.erp_cust_az12 asc eca 
	on cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela 
	on cci.cst_key = ela.cid;

--------------------------------------------------------------PRODUCT
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
from silver.crm_prd_info as cpi
left join silver.erp_px_cat_g1v2 as epcgv 
on cpi.cat_id=epcgv.id 
where 
cpi.prd_end_dt is null --only active





