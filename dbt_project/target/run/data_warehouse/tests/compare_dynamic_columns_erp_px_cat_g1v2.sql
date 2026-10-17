
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."compare_dynamic_columns_erp_px_cat_g1v2"
    
      
    ) dbt_internal_test