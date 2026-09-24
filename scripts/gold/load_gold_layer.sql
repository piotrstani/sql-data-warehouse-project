--------------------------------------------------------------CUSTOMER
select
	cci.cst_id,
	cci.cst_key,
	cci.cst_firstname,
	cci.cst_lastname,
	cci.cst_marital_status,
	case when cci.cst_gndr != 'n/a' then cci.cst_gndr
	else coalesce (eca.gen, 'n/a') end as new_gen,
	cci.cst_create_date,
	eca.bdate,	
	ela.cntry 
from silver.crm_cust_info cci
left join silver.erp_cust_az12 eca 
	on cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela 
	on cci.cst_key = ela.cid 
	
--------------------------------------------------------------PRODUCT
