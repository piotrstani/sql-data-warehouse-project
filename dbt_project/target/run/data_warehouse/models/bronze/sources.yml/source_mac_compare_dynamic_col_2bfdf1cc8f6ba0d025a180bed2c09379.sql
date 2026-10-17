
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."source_mac_compare_dynamic_col_2bfdf1cc8f6ba0d025a180bed2c09379"
    
      
    ) dbt_internal_test