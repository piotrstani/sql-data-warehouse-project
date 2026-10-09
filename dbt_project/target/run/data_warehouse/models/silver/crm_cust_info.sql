
  
    

  create  table "DataWarehouse"."silver"."crm_cust_info__dbt_tmp"
  
  
    
  
  (
    cst_id integer,
    cst_key varchar(50),
    cst_firstname TEXT,
    cst_lastname TEXT,
    cst_marital_status TEXT,
    cst_gndr TEXT,
    cst_create_date date
    
    )
 ;
    insert into "DataWarehouse"."silver"."crm_cust_info__dbt_tmp" (
      cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    )
  
  (
    
    select cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    from (
        

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
    ) as model_subq
  );
  