
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_source_expect_30f7bf32daad303a2a60222d37ac692e"
    
      
    ) dbt_internal_test