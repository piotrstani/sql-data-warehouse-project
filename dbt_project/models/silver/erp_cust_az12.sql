{{ config(
    materialized='table',
    unique_key='cid'
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
	 else 'n/a' end as gen
FROM source_data
)

SELECT * FROM transformed_data src
