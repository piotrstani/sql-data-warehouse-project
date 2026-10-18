
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_source_expect_e75fd4c8affe4ef3c8c7b8b801a929db"
    
      
    ) dbt_internal_test