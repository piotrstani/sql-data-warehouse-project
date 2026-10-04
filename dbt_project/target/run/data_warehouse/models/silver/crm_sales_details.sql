
      insert into "DataWarehouse"."silver"."crm_sales_details" ("sls_ord_num", "sls_prd_key", "sls_cust_id", "sls_order_dt", "sls_ship_dt", "sls_due_dt", "sls_sales", "sls_quantity", "sls_price")
    (
        select "sls_ord_num", "sls_prd_key", "sls_cust_id", "sls_order_dt", "sls_ship_dt", "sls_due_dt", "sls_sales", "sls_quantity", "sls_price"
        from "crm_sales_details__dbt_tmp163238784690"
    )


  