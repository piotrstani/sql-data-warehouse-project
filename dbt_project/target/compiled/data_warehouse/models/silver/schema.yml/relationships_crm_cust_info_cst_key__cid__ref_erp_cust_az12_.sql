
    
    

with child as (
    select cst_key as from_field
    from "DataWarehouse"."silver"."crm_cust_info"
    where cst_key is not null
),

parent as (
    select cid as to_field
    from "DataWarehouse"."silver"."erp_cust_az12"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


