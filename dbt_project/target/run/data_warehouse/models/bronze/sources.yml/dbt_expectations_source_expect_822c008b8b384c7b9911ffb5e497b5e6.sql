
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_source_expect_822c008b8b384c7b9911ffb5e497b5e6"
    
      
    ) dbt_internal_test