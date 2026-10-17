
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."source_compare_dynamic_columns_0ed47064e8f6aece10ae183464c1c92a"
    
      
    ) dbt_internal_test