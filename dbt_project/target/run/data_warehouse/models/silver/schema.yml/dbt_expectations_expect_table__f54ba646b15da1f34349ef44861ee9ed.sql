
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."dbt_expectations_expect_table__f54ba646b15da1f34349ef44861ee9ed"
    
      
    ) dbt_internal_test