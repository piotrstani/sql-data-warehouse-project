
SELECT  count(*)   FROM "DataWarehouse"."silver"."crm_cust_info"
    having count(*) < 1
