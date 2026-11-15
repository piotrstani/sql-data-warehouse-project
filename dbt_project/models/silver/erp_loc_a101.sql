{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('bronze', 'erp_loc_a101') }}
),

transformed_data AS (
SELECT
replace(cid,'-','') as cid,
case when UPPER(TRIM(cntry)) in ('US','USA') then 'United States'
	 when UPPER(TRIM(cntry)) in ('DE') then 'Germany'
	 when UPPER(TRIM(cntry)) = '' or cntry is null then 'n/a'
	 else TRIM(cntry) end as cntry,

     -- Znacznik bieżącego ładowania (table: odświeżany przy każdym dbt run).
    {{ current_timestamp() }} AS dwh_create_ts,

    -- Airflow przekaże wspólny identyfikator batcha przez --vars.
    -- Bez niego wykorzystujemy invocation_id bieżącego polecenia dbt.
    '{{ var("dwh_batch_id", invocation_id) | replace("'", "''") }}'::varchar(255) AS dwh_batch_id,

    'ERP'::varchar(50) AS dwh_source_system
FROM source_data
)

SELECT * FROM transformed_data src
