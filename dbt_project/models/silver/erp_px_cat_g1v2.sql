{{ config(
    materialized='table',
    unique_key='id'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('bronze', 'erp_px_cat_g1v2') }}
),

transformed_data AS (
SELECT
id,
cat,
subcat,
maintenance,

 -- Znacznik bieżącego ładowania (table: odświeżany przy każdym dbt run).
{{ current_timestamp() }} AS dwh_create_ts,

-- Airflow przekaże wspólny identyfikator batcha przez --vars.
-- Bez niego wykorzystujemy invocation_id bieżącego polecenia dbt.
'{{ var("dwh_batch_id", invocation_id) | replace("'", "''") }}'::varchar(255) AS dwh_batch_id,

'ERP'::varchar(50) AS dwh_source_system

FROM source_data
)

SELECT * FROM transformed_data src
