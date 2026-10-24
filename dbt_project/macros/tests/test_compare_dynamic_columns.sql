{% test mac_compare_dynamic_columns(model, column_name, compare_to_relation, exclude_columns=[]) %}

    -- Używamy makra dbt do pobrania obiektów kolumn z bazy z relacji źródłowej (compare_to_relation)
    {%- set columns = adapter.get_columns_in_relation(compare_to_relation) -%}

    -- Wyciągamy same nazwy kolumn, omijając te z listy wykluczeń
    {%- set column_names = [] -%}
    {%- for col in columns -%}
        -- Filtr case-insensitive
        {%- if col.name | lower not in exclude_columns | map('lower') | list -%}
            {%- do column_names.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}

    -- Łączymy nazwy w jeden ciąg znaków oddzielony przecinkami
    {%- set columns_csv = column_names | join(', ') -%}

    -- Krok 1: Wiersze w modelu bazowym, których nie ma (lub są inne) w relacji porównywanej
    SELECT {{ columns_csv }}
    FROM {{ model }}
    EXCEPT
    SELECT {{ columns_csv }}
    FROM {{ compare_to_relation }}

    UNION ALL

    -- Krok 2: Wiersze w relacji porównywanej, których nie ma (lub są inne) w modelu bazowym
    SELECT {{ columns_csv }}
    FROM {{ compare_to_relation }}
    EXCEPT
    SELECT {{ columns_csv }}
    FROM {{ model }}

{% endtest %}