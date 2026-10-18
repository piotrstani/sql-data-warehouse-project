{{ config(
    materialized='table',
    unique_key='id'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('bronze', 'epcg') }}
),

transformed_data AS (
SELECT
id,
cat,
subcat,
maintenance
FROM source_data
)

SELECT * FROM transformed_data src
