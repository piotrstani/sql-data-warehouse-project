------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------
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