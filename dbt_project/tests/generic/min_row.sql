{% test min_row( model, min_row_cnt) %}
{{ config(severity = 'warn') }}
SELECT  count(*)   FROM {{ model }}
    having count(*) < {{ min_row_cnt }}
{% endtest %}
