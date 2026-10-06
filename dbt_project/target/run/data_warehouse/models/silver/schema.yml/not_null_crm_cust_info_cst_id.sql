
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select cst_id
from "DataWarehouse"."silver"."crm_cust_info"
where cst_id is null



  
  
      
    ) dbt_internal_test