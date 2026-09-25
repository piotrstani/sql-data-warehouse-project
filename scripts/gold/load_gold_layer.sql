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
left join silver.erp_cust_az12 as eca 
	on cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela 
	on cci.cst_key = ela.cid;

--------------------------------------------------------------PRODUCTS
create view gold.dim_products as
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
where cpi.prd_end_dt is null; --only active


--------------------------------------------------------------SALES
create view gold.fact_sales as
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
from silver.crm_sales_details as csd
left join gold.dim_products as dp 
	on csd.sls_prd_key = dp.product_number 
left join gold.dim_customers  as dc 
	on csd.sls_cust_id = dc.customer_id;

---test
select * from gold.fact_sales t 
left join gold.dim_customers dc 
on t.customer_key =dc.customer_key 
left join gold.dim_products dp 
on t.product_key =dp.product_key 
--where dc.customer_key is null 
where dp.product_key  is null 




