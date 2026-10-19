


    with grouped_expression as (
    select
        
        
    
  
count(distinct cntry) = 7
 as expression


    from "DataWarehouse"."bronze"."erp_loc_a101"
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors


