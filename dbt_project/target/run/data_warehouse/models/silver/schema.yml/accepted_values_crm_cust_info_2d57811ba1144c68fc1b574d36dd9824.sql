
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        cst_marital_status as value_field,
        count(*) as n_records

    from "DataWarehouse"."silver"."crm_cust_info"
    group by cst_marital_status

)

select *
from all_values
where value_field not in (
    'Single','Married'
)



  
  
      
    ) dbt_internal_test