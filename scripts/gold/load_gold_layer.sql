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

--Description
COMMENT ON VIEW gold.dim_customers IS 'Stores customer details enriched with demographic and geographic data';

--Description columns
COMMENT ON COLUMN gold.dim_customers.customer_key IS 'Surrogate key uniquely identifying each customer record in the dimension table';
COMMENT ON COLUMN gold.dim_customers.customer_id IS 'Unique numerical identifier assigned to each customer';
COMMENT ON COLUMN gold.dim_customers.customer_number IS 'Alphanumeric identifier representing the customer, used for tracking and referencing';
COMMENT ON COLUMN gold.dim_customers.first_name IS 'The customer''s first name, as recorded in the system';
COMMENT ON COLUMN gold.dim_customers.last_name IS 'The customer''s last name or family name';
COMMENT ON COLUMN gold.dim_customers.country IS 'The country of residence for the customer';
COMMENT ON COLUMN gold.dim_customers.martial_status IS 'The marital status of the customer';
COMMENT ON COLUMN gold.dim_customers.gender IS 'The gender of the customer';
COMMENT ON COLUMN gold.dim_customers.birthdate IS 'The date of birth of the customer, formatted as YYYY-MM-DD';
COMMENT ON COLUMN gold.dim_customers.create_date IS 'The date and time when the customer record was created in the system';


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

--Description
COMMENT ON VIEW gold.dim_products IS 'Provides information about the products and their attributes';

--Description columns
COMMENT ON COLUMN gold.dim_products.product_key IS 'Surrogate key uniquely identifying each product record in the product dimension table';
COMMENT ON COLUMN gold.dim_products.product_id IS 'A unique identifier assigned to the product for internal tracking and referencing';
COMMENT ON COLUMN gold.dim_products.product_number IS 'A structured alphanumeric code representing the product, often used for categorization or inventor';
COMMENT ON COLUMN gold.dim_products.product_name IS 'Descriptive name of the product, including key details such as type, color, and size';
COMMENT ON COLUMN gold.dim_products.category_id IS 'A unique identifier for the product''s category, linking to its high-level classification';
COMMENT ON COLUMN gold.dim_products.category IS 'The broader classification of the product (e.g., Bikes, Components) to group related items';
COMMENT ON COLUMN gold.dim_products.subcategory IS 'A more detailed classification of the product within the category, such as product type';
COMMENT ON COLUMN gold.dim_products.maintenance IS 'Indicates whether the product requires maintenance';
COMMENT ON COLUMN gold.dim_products.cost IS 'The cost or base price of the product, measured in monetary units';
COMMENT ON COLUMN gold.dim_products.product_line IS 'The specific product line or series to which the product belongs';
COMMENT ON COLUMN gold.dim_products.start_date IS 'The date when the product became available for sale or use, stored in';

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

--Description
COMMENT ON VIEW gold.fact_sales IS 'Stores transactional sales data for analytical purposes';

--Description columns
COMMENT ON COLUMN gold.fact_sales.order_number IS 'A unique alphanumeric identifier for each sales order';
COMMENT ON COLUMN gold.fact_sales.product_key IS 'Surrogate key linking the order to the product dimension table';
COMMENT ON COLUMN gold.fact_sales.customer_key IS 'Surrogate key linking the order to the customer dimension table';
COMMENT ON COLUMN gold.fact_sales.order_date IS 'The date when the order was placed';
COMMENT ON COLUMN gold.fact_sales.shipping_date IS 'The date when the order was shipped to the customer';
COMMENT ON COLUMN gold.fact_sales.due_dt IS 'The date when the order payment was due';
COMMENT ON COLUMN gold.fact_sales.sales_amount IS 'The total monetary value of the sale for the line item, in whole currency units';
COMMENT ON COLUMN gold.fact_sales.quantity IS 'The number of units of the product ordered for the line item';
COMMENT ON COLUMN gold.fact_sales.price IS 'The price per unit of the product for the line item, in whole currency units';


---test
select * from gold.fact_sales t
left join gold.dim_customers dc
on t.customer_key =dc.customer_key
left join gold.dim_products dp
on t.product_key =dp.product_key
--where dc.customer_key is null
where dp.product_key  is null;


