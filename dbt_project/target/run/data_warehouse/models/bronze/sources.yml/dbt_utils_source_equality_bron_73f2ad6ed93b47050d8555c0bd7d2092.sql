
    
    select
      
    count(*) + coalesce(abs(
        sum(case when which_diff = 'a_minus_b' then 1 else 0 end) -
        sum(case when which_diff = 'b_minus_a' then 1 else 0 end)
    ), 0)
 as failures,
      
    count(*) + coalesce(abs(
        sum(case when which_diff = 'a_minus_b' then 1 else 0 end) -
        sum(case when which_diff = 'b_minus_a' then 1 else 0 end)
    ), 0)
 != 0 as should_warn,
      
    count(*) + coalesce(abs(
        sum(case when which_diff = 'a_minus_b' then 1 else 0 end) -
        sum(case when which_diff = 'b_minus_a' then 1 else 0 end)
    ), 0)
 != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_utils_source_equality_bron_73f2ad6ed93b47050d8555c0bd7d2092"
    
      
    ) dbt_internal_test