---------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------
--silver.crm_cust_info
--/*----------------------------Nulls,Duplicates in PK----------------------------
select
cst_id,
count(*) as cnt
from bronze.crm_cust_info
group by cst_id having count(*) > 1 or cst_id is null order by cnt desc;

select *,
row_number() over (partition by cst_id order by cst_create_date desc) as pk_flg
from bronze.crm_cust_info
where cst_id ='29433'
ORDER BY cst_id, cst_create_date DESC;

select  DISTINCT ON (cst_id) *
from	bronze.crm_cust_info
where cst_id ='29433'
ORDER BY cst_id, cst_create_date DESC;

------------------Unwanted Spaces---------------------------------------------
select cst_firstname
from bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname );

select cst_lastname
from bronze.crm_cust_info
where cst_lastname != TRIM(cst_firstname );

-------------------Standardization & Consistency------------------------------
select distinct cst_marital_status, cst_gndr
from bronze.crm_cust_info;
------------------------------------------------------------------------------*/

-----------------------------------------------------silver.crm_cust_info------------------------INSERT
insert into silver.crm_cust_info
select
	cst_id,
	cst_key,
	TRIM (cst_firstname) as cst_firstname,
	TRIM (cst_lastname) as cst_lastname,
	case when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
		 when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
		 else 'n/a' end as cst_marital_status,
	case when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
		 when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
		 else 'n/a' end as cst_gndr,
	cst_create_date
from (
select DISTINCT ON (cst_id) * f
rom bronze.crm_cust_info ORDER BY cst_id, cst_create_date desc);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------
--silver.crm_prd_info
--/*----------------------------Nulls,Duplicates in PK----------------------------
select
prd_id,
count(*) as cnt
from bronze.crm_prd_info
group by prd_id having count(*) > 1 or prd_id is null order by cnt ;

---------------------------------------FK----------------------------------------
SELECT * from (
SELECT
prd_key,
replace (substring(prd_key, 1, 5), '-', '_') as cat_id
FROM bronze.crm_prd_info
) where cat_id not in ( select cat_id from bronze.erp_px_cat_g1v2 )

SELECT * from (
SELECT
substring(prd_key, 7, LENGTH(prd_key)) as prd_key
FROM bronze.crm_prd_info
) where substring(prd_key, 7, LENGTH(prd_key)) not in ( select sls_prd_key from bronze.crm_sales_details)

------------------Unwanted Spaces---------------------------------------------
select prd_nm
from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm )

------------------Nulls, negtive values---------------------------------------------
select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null

-------------------Standardization & Consistency------------------------------
select distinct prd_line
from bronze.crm_prd_info

-------------------Date validation------------------------------
select distinct prd_start_dt,  prd_end_dt, *
from bronze.crm_prd_info
where prd_end_dt <  prd_start_dt
order by prd_id
------------------------------------------------------------------------------*/

-----------------------------------------------------silver.crm_prd_info-------------------------INSERT
insert into silver.crm_prd_info
SELECT
prd_id,  /*PK*/
--prd_key,
replace (substring(prd_key, 1, 5), '-', '_') as cat_id, /*FK, 'AC_BR', select cat_id from bronze.erp_px_cat_g1v2*/
substring(prd_key, 7, LENGTH(prd_key)) as prd_key, /*FK, 'HL-U509', select sls_prd_key from bronze.crm_sales_details*/
prd_nm,
coalesce(prd_cost, 0) as prd_cost,
case UPPER(TRIM(prd_line))
	when 'M' then 'Moutain'
	when 'R' then 'Road'
	when 'S' then 'Other Sales'
	when 'T' then 'Touring'
	else 'n/a' end as prd_line,
prd_start_dt,
--prd_end_dt,
LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt ) - 1 as prd_end_dt /*new end_dt from start_dt */
FROM bronze.crm_prd_info
------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------
--silver.crm_sales_details
--/*----------------------------Nulls,Duplicates in PK----------------------------
select
sls_ord_num,
count(*) as cnt
from bronze.crm_sales_details
group by sls_ord_num having count(*) > 1 or sls_ord_num is null order by cnt ;

---------------------------------------FK----------------------------------------
SELECT * from (
SELECT
sls_cust_id
FROM bronze.crm_sales_details
) where sls_cust_id not in ( select cst_id from silver.crm_cust_info)

SELECT * from (
SELECT
sls_prd_key
FROM bronze.crm_sales_details
) where sls_prd_key  in ( select prd_key from silver.crm_prd_info)

-------------------Date validation------------------------------
select sls_ord_num,
sls_order_dt,
nullif(sls_order_dt, 0) as sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 or	sls_ship_dt	<= 0 or sls_due_dt <= 0

select sls_ord_num,
sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where sls_order_dt::varchar !~ '\d{8}'
or sls_ship_dt::varchar !~ '\d{8}'
or sls_due_dt::varchar !~ '\d{8}'

select sls_ord_num,
sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where (sls_order_dt > '20500101' or  sls_order_dt < '19000101')
or (sls_ship_dt > '20500101' or  sls_order_dt < '19000101')
or (sls_due_dt > '20500101' or  sls_order_dt < '19000101')


select sls_ord_num,
sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt
or sls_order_dt > sls_due_dt
or sls_ship_dt > sls_due_dt


------------------Data consistency---------------------------------------------
select sls_ord_num,
sls_sales,
sls_quantity,
sls_price,
case when sls_quantity * sls_price != sls_sales then 1 else 0 end as qps_flg,
case when sls_quantity is null or  sls_price is null or sls_sales is null then 1 else 0 end as null_flg,
case when sls_quantity <= 0 or  sls_price <= 0 or sls_sales <= 0 then 1 else 0 end as negtive_flg
from bronze.crm_sales_details
where sls_quantity * sls_price != sls_sales
or (sls_quantity is null or  sls_price is null or sls_sales is null)
or (sls_quantity <= 0 or  sls_price <= 0 or sls_sales <= 0)

--rueles
--1) if sls_sales is negative, zero or null: sls_quantity * sls_price
--2) if sls_price is zero or null: sls_quantity * sls_sales
--3) if sls_price is negative convert to positive
------------------------------------------------------------------------------*/

-----------------------------------------------------silver.crm_sales_details-------------------------INSERT
insert into silver.crm_sales_details
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
from
	bronze.crm_sales_details;
------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--silver.erp_cust_az12
--/*----------------------------Nulls,Duplicates in PK----------------------------
select
cid,
count(*) as cnt
from bronze.erp_cust_az12
group by cid having count(*) > 1 or cid is null order by cnt ;

---------------------------------------FK----------------------------------------
SELECT * from (
SELECT
cid
FROM bronze.erp_cust_az12
) where case when cid ~ '^NAS' then substring(cid,4,length(cid))
else cid end in ( select cst_key from silver.crm_cust_info)


-------------------Date validation------------------------------
select
cid,
bdate
from bronze.erp_cust_az12
where (bdate > CURRENT_DATE or  bdate < '19200101')
order by bdate asc;
------------------Data consistency---------------------------------------------

select distinct
gen,
case when UPPER(TRIM(gen)) in ('F','FEMALE') then 'Female'
	 when UPPER(TRIM(gen)) in ('M','MALE') then 'Male'
	 else 'n/a' end as gen

from bronze.erp_cust_az12
------------------------------------------------------------------------------*/

-----------------------------------------------------silver.erp_cust_az12-------------------------INSERT
insert into silver.erp_cust_az12
SELECT
case when cid ~ '^NAS' then substring(cid,4,length(cid))
	else cid end as cid,
case when bdate > CURRENT_DATE then null
else bdate end as bdate,
case when UPPER(TRIM(gen)) in ('F','FEMALE') then 'Female'
	 when UPPER(TRIM(gen)) in ('M','MALE') then 'Male'
	 else 'n/a' end as gen
FROM bronze.erp_cust_az12
------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--silver.erp_loc_a101
--/*----------------------------Nulls,Duplicates in PK----------------------------
select
cid,
count(*) as cnt
from bronze.erp_loc_a101
group by cid having count(*) > 1 or cid is null order by cnt ;

---------------------------------------FK----------------------------------------
SELECT * from (
SELECT
replace(cid,'-','') as cid

FROM bronze.erp_loc_a101
) where replace(cid,'-','') not in ( select cst_key from silver.crm_cust_info)



------------------Data consistency---------------------------------------------
select distinct
cntry,
case when UPPER(TRIM(cntry)) in ('US','USA') then 'United States'
	 when UPPER(TRIM(cntry)) in ('DE') then 'Germany'
	 when UPPER(TRIM(cntry)) = '' or cntry is null then 'n/a'
	 else TRIM(cntry) end as cntry
from bronze.erp_loc_a101
------------------------------------------------------------------------------*/

-----------------------------------------------------silver.erp_loc_a101-------------------------INSERT
insert into silver.erp_loc_a101

SELECT
replace(cid,'-','') as cid,
case when UPPER(TRIM(cntry)) in ('US','USA') then 'United States'
	 when UPPER(TRIM(cntry)) in ('DE') then 'Germany'
	 when UPPER(TRIM(cntry)) = '' or cntry is null then 'n/a'
	 else TRIM(cntry) end as cntry
FROM bronze.erp_loc_a101;
------------------------------------------------------------------------------------------------



