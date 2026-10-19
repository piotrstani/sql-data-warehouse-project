




    with grouped_expression as (
    select
        
        
    
  


    

coalesce(array_length((select regexp_matches(cntry, '\w+', '')), 1), 0)


 > 0
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




