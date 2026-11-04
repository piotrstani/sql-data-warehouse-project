{% test sales_amount_matches(model, quantity_column, price_column, sales_column) %}

SELECT
    *
FROM {{ model }}
WHERE
    {{ quantity_column }} IS NULL
    OR {{ price_column }} IS NULL
    OR {{ sales_column }} IS NULL
    OR (
        {{ quantity_column }}::bigint
        * {{ price_column }}::bigint
    ) <> {{ sales_column }}::bigint

{% endtest %}
