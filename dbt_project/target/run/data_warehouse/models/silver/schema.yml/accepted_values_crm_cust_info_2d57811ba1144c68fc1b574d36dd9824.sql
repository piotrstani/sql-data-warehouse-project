
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."accepted_values_crm_cust_info_2d57811ba1144c68fc1b574d36dd9824"
    
      
    ) dbt_internal_test