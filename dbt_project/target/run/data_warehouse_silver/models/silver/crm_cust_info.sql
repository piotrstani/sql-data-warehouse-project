
      
        
        
        delete from "DataWarehouse"."silver"."crm_cust_info" as DBT_INTERNAL_DEST
        where (cst_id) in (
            select distinct cst_id
            from "crm_cust_info__dbt_tmp131550710282" as DBT_INTERNAL_SOURCE
        );

    

    insert into "DataWarehouse"."silver"."crm_cust_info" ("cst_id", "cst_key", "cst_firstname", "cst_lastname", "cst_marital_status", "cst_gndr", "cst_create_date")
    (
        select "cst_id", "cst_key", "cst_firstname", "cst_lastname", "cst_marital_status", "cst_gndr", "cst_create_date"
        from "crm_cust_info__dbt_tmp131550710282"
    )
  