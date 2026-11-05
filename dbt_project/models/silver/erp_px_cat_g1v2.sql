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
{{ current_timestamp() }} AS dwh_create_ts
FROM source_data
)

SELECT * FROM transformed_data src
