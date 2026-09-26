
  
    

  create  table "DataWarehouse"."silver"."crm_cust_info__dbt_tmp"
  
  
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
    -- Deduplikacja danych źródłowych z warstwy Bronze
    SELECT DISTINCT ON (cst_id) *
    FROM "DataWarehouse"."bronze"."crm_cust_info"
    WHERE cst_id is not null
    ORDER BY cst_id, cst_create_date DESC
),

transformed_data AS (
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        -- Standaryzacja statusu cywilnego
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        -- Standaryzacja płci
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM source_data
)

SELECT * FROM transformed_data src
/*

*/


-- Przetwarzaj tylko klientów zaktualizowanych/dodanych od wczoraj

  );
  