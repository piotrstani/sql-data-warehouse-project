{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('bronze', 'erp_cust_az12') }}
),

transformed_data AS (
SELECT
case when cid ~ '^NAS' then substring(cid,4,length(cid))
	else cid end as cid,
case when bdate > CURRENT_DATE then null
else bdate end as bdate,
case when UPPER(TRIM(gen)) in ('F','FEMALE') then 'Female'
	 when UPPER(TRIM(gen)) in ('M','MALE') then 'Male'
	 else 'n/a' end as gen,

     -- Znacznik bieżącego ładowania (table: odświeżany przy każdym dbt run).
    {{ current_timestamp() }} AS dwh_create_ts,

    -- Airflow przekaże wspólny identyfikator batcha przez --vars.
    -- Bez niego wykorzystujemy invocation_id bieżącego polecenia dbt.
    '{{ var("dwh_batch_id", invocation_id) | replace("'", "''") }}'::varchar(255) AS dwh_batch_id,

    'ERP'::varchar(50) AS dwh_source_system


FROM source_data
)

SELECT * FROM transformed_data src
