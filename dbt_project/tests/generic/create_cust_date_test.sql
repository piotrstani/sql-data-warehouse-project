{% test create_cust_date_test( model, column_name, cutoff_date) %}
SELECT  *   FROM {{ model }} where {{column_name}} <= '{{ cutoff_date }}'
{% endtest %}
