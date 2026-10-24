SELECT cci.* FROM {{ ref('crm_cust_info') }} AS cci
WHERE cst_firstname IN ('Jonxxx')