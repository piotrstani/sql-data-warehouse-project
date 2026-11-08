
{% macro postgres__get_columns_in_relation(relation) %}

    {% call statement('get_columns_in_relation', fetch_result=True) %}

        SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            numeric_scale

        FROM information_schema.columns

        WHERE table_name = '{{ relation.identifier }}'

        {% if relation.schema %}
          AND table_schema = '{{ relation.schema }}'
        {% endif %}

        ORDER BY ordinal_position

    {% endcall %}

    {% set table = load_result('get_columns_in_relation').table %}

    {{ return(sql_convert_columns_in_relation(table)) }}

{% endmacro %}
