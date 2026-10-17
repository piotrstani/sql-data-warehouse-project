
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."source_compare_dynamic_columns_3ad32e0337f1b41abc6ddb49dd29861d"
    
      
    ) dbt_internal_test