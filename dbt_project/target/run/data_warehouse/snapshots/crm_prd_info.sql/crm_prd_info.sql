
      update "DataWarehouse"."silver"."crm_prd_info"
    set dbt_valid_to = DBT_INTERNAL_SOURCE.dbt_valid_to
    from "crm_prd_info__dbt_tmp203647461259" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_scd_id::text = "DataWarehouse"."silver"."crm_prd_info".dbt_scd_id::text
      and DBT_INTERNAL_SOURCE.dbt_change_type::text in ('update'::text, 'delete'::text)
      
        and "DataWarehouse"."silver"."crm_prd_info".dbt_valid_to is null;
      


    insert into "DataWarehouse"."silver"."crm_prd_info" ("prd_id", "cat_id", "prd_key", "prd_nm", "prd_cost", "prd_line", "prd_start_dt", "prd_end_dt", "dbt_updated_at", "dbt_valid_from", "dbt_valid_to", "dbt_scd_id")
    select DBT_INTERNAL_SOURCE."prd_id",DBT_INTERNAL_SOURCE."cat_id",DBT_INTERNAL_SOURCE."prd_key",DBT_INTERNAL_SOURCE."prd_nm",DBT_INTERNAL_SOURCE."prd_cost",DBT_INTERNAL_SOURCE."prd_line",DBT_INTERNAL_SOURCE."prd_start_dt",DBT_INTERNAL_SOURCE."prd_end_dt",DBT_INTERNAL_SOURCE."dbt_updated_at",DBT_INTERNAL_SOURCE."dbt_valid_from",DBT_INTERNAL_SOURCE."dbt_valid_to",DBT_INTERNAL_SOURCE."dbt_scd_id"
    from "crm_prd_info__dbt_tmp203647461259" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_change_type::text = 'insert'::text;

  