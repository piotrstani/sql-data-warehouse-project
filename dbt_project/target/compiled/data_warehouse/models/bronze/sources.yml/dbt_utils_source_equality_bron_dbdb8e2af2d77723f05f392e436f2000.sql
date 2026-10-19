



-- setup



with a as (

    select * from "DataWarehouse"."bronze"."erp_cust_az12"

),

b as (

    select * from "DataWarehouse"."silver"."erp_cust_az12"

),

a_minus_b as (

    select cid, bdate, gen from a
    

    except


    select cid, bdate, gen from b

),

b_minus_a as (

    select cid, bdate, gen from b
    

    except


    select cid, bdate, gen from a

),

unioned as (

    select 'a_minus_b' as which_diff, a_minus_b.* from a_minus_b
    union all
    select 'b_minus_a' as which_diff, b_minus_a.* from b_minus_a

)

select * from unioned

