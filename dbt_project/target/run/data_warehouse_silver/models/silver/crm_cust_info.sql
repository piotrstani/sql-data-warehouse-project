
      -- back compat for old kwarg name
  
  
        
            
            
            
            
        
    

    

    merge into "DataWarehouse"."silver"."crm_cust_info" as DBT_INTERNAL_DEST
        using "crm_cust_info__dbt_tmp141437279697" as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.cst_id = DBT_INTERNAL_DEST.cst_id))

    
    when matched then update set
        "cst_id" = DBT_INTERNAL_SOURCE."cst_id","cst_key" = DBT_INTERNAL_SOURCE."cst_key","cst_firstname" = DBT_INTERNAL_SOURCE."cst_firstname","cst_lastname" = DBT_INTERNAL_SOURCE."cst_lastname","cst_marital_status" = DBT_INTERNAL_SOURCE."cst_marital_status","cst_gndr" = DBT_INTERNAL_SOURCE."cst_gndr","cst_create_date" = DBT_INTERNAL_SOURCE."cst_create_date"
    

    when not matched then insert
        ("cst_id", "cst_key", "cst_firstname", "cst_lastname", "cst_marital_status", "cst_gndr", "cst_create_date")
    values
        ("cst_id", "cst_key", "cst_firstname", "cst_lastname", "cst_marital_status", "cst_gndr", "cst_create_date")


  