{{ config(
    materialized='table',
    unique_key='cid'
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
	 else TRIM(cntry) end as cntry
FROM source_data
)

SELECT * FROM transformed_data src
