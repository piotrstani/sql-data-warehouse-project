
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_source_expect_ea7d172a2a02a2e86c8eaaf2b001d6af"
    
      
    ) dbt_internal_test