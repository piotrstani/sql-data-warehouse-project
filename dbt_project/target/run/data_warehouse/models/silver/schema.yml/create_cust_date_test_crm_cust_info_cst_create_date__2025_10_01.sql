
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "DataWarehouse"."_test_failures"."create_cust_date_test_crm_cust_info_cst_create_date__2025_10_01"
    
      
    ) dbt_internal_test