
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."accepted_values_crm_cust_info_718b81d6c1c1931b2e18e8ae84caccfa"
    
      
    ) dbt_internal_test