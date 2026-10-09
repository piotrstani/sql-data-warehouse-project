{% test create_cust_date_test( model, column_name) %}
SELECT  *   FROM {{ model }} where {{column_name}} <= '2025-10-01'
{% endtest %}
