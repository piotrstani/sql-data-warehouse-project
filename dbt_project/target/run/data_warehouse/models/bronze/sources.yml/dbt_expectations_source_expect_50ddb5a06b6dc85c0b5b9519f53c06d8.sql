
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_source_expect_50ddb5a06b6dc85c0b5b9519f53c06d8"
    
      
    ) dbt_internal_test