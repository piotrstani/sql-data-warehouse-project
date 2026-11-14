{{ config(
    materialized='table',
    event_time='cst_create_date'
) }}

WITH source_data AS (
    -- Deduplikacja danych źródłowych z warstwy Bronze
    SELECT DISTINCT ON (cst_id)
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    FROM {{ source('bronze', 'crm_cust_info') }}
    WHERE cst_id is not null
    ORDER BY
    cst_id,
    cst_create_date DESC NULLS LAST,
    cst_key DESC NULLS LAST,
    cst_firstname DESC NULLS LAST,
    cst_lastname DESC NULLS LAST,
    cst_marital_status DESC NULLS LAST,
    cst_gndr DESC NULLS LAST
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
        cst_create_date,

         -- Znacznik bieżącego ładowania (table: odświeżany przy każdym dbt run).
        {{ current_timestamp() }} AS dwh_create_ts,

        -- Airflow przekaże wspólny identyfikator batcha przez --vars.
        -- Bez niego wykorzystujemy invocation_id bieżącego polecenia dbt.
        '{{ var("dwh_batch_id", invocation_id) | replace("'", "''") }}'::varchar(255) AS dwh_batch_id,

        'CRM'::varchar(50) AS dwh_source_system

    FROM source_data

)

SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    dwh_create_ts,
    dwh_batch_id,
    dwh_source_system
FROM transformed_data