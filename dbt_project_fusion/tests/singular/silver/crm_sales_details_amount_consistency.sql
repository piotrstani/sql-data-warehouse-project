{{ config(tags=['test_crm_sales_amount_consistency'], severity='error') }}

SELECT
    sls_ord_num,
    sls_quantity,
    sls_price,
    sls_sales,
    sls_quantity::bigint * sls_price::bigint AS calculated_sales
FROM {{ ref('crm_sales_details') }}
WHERE sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales IS NULL
   OR sls_quantity::bigint * sls_price::bigint <> sls_sales::bigint