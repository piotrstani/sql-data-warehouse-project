
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    cst_id as unique_field,
    count(*) as n_records

from "DataWarehouse"."silver"."crm_cust_info"
where cst_id is not null
group by cst_id
having count(*) > 1



  
  
      
    ) dbt_internal_test