{% macro learn_variables() %}

    {% set jinja_var1 = "there!" %}
    {{ log("And hello " ~ jinja_var1, info=True) }}

    {{ log("Hello dbt user " ~ var("user_name", "NO NAME IS SET!") ~ "!", info=True) }}
{% endmacro %}