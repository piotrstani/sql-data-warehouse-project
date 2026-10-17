
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."source_compare_dynamic_columns_275707ba9fb699feda467ad11f86e7c0"
    
      
    ) dbt_internal_test