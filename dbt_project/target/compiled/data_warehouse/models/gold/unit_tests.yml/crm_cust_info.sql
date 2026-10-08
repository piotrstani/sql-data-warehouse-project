
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