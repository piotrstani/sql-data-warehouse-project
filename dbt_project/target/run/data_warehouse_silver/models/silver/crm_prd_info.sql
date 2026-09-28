
  
    

  create  table "DataWarehouse"."silver"."crm_prd_info__dbt_tmp"
  
  
    as
  
  (
    --Ustawienia zadeklarowane bezpośrednio w pliku .sql zawsze nadpisują te globalne z pliku dbt_project.yml.
/*
 --append-only


-- Przetwarzaj tylko klientów zaktualizowanych/dodanych od wczoraj
 unique_key do dopasowania rekordu wejściowego do już istniejącego rekordu w tabeli docelowej,
 np. aby go zaktualizować albo zastąpić, zależnie od adaptera i strategii incremental.
 Sama konfiguracja nie jest ogólną gwarancją constraintu UNIQUE w bazie


 -------------------------------------------------------------------
 --Strategia merge wykonuje upsert: rekord o tym samym unique_key jest aktualizowany, a nowy klucz jest dodawany


*/



WITH source_data AS (
    SELECT *
    FROM "DataWarehouse"."bronze"."crm_prd_info"
),

transformed_data AS (
    SELECT
    prd_id,  /*PK*/
    --prd_key,
    replace (substring(prd_key, 1, 5), '-', '_') as cat_id, /*FK, 'AC_BR', select cat_id from bronze.erp_px_cat_g1v2*/
    substring(prd_key, 7, LENGTH(prd_key)) as prd_key, /*FK, 'HL-U509', select sls_prd_key from bronze.crm_sales_details*/
    prd_nm,
    coalesce(prd_cost, 0) as prd_cost,
    case UPPER(TRIM(prd_line))
        when 'M' then 'Moutain'
        when 'R' then 'Road'
        when 'S' then 'Other Sales'
        when 'T' then 'Touring'
        else 'n/a' end as prd_line,
    prd_start_dt,
    --prd_end_dt,
    LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt ) - 1 as prd_end_dt /*new end_dt from start_dt */
    FROM source_data
)

SELECT * FROM transformed_data src
  );
  