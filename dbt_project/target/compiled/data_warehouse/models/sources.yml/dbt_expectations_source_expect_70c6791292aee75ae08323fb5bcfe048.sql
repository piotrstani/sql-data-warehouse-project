





    with grouped_expression as (
    select
        
        
    
  
( 1=1 and percentile_cont(0.95) within group (order by sls_price) >= 0 and percentile_cont(0.95) within group (order by sls_price) <= 200
)
 as expression


    from "DataWarehouse"."bronze"."crm_sales_details"
    

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





