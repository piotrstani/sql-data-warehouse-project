with fact_sales as (
SELECT * FROM {{ ref('fact_sales') }}
)
, dim_products as (
SELECT * FROM {{ ref('dim_products') }}
)

SELECT
EXTRACT(YEAR FROM fs.order_date) as order_year,
dp.subcategory,
SUM(fs.sales_amount) as sales_amount_yearly
FROM fact_sales fs
inner join dim_products dp
on fs.product_key =dp.product_key
group by order_year, dp.subcategory
order by dp.subcategory asc, order_year desc