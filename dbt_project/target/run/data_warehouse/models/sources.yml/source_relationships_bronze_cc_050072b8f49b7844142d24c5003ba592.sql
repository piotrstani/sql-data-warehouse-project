
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."source_relationships_bronze_cc_050072b8f49b7844142d24c5003ba592"
    
      
    ) dbt_internal_test