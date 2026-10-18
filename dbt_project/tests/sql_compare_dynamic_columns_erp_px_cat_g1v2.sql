---erp_px_cat_g1v2 brak transformacij
{% set source_relation = source('bronze', 'epcg') %}
{% set target_relation = ref('erp_px_cat_g1v2') %}

-- 1. Zdefiniuj listę kolumn, które chcesz pominąć w porównaniu (np. techniczne timestampy)
{% set exclude_columns = ['maintenance'] %}

-- Używamy makra dbt do pobrania obiektów kolumn z bazy
{%- set columns = adapter.get_columns_in_relation(source_relation) -%}

-- Wyciągamy same nazwy kolumn, omijając te z listy wykluczeń
{%- set column_names = [] -%}
{%- for col in columns -%}
    -- Filtr case-insensitive: zamieniamy nazwy na małe litery, by uniknąć problemów z wielkością znaków
    {%- if col.name | lower not in exclude_columns | map('lower') | list -%}
        {%- do column_names.append(col.name) -%}
    {%- endif -%}
{%- endfor -%}
{%- set columns_csv = column_names | join(', ') -%}

-- Krok 1: Wiersze w modelu, których nie ma (lub są inne) w źródle
SELECT {{ columns_csv }}
FROM {{ target_relation }}
EXCEPT
SELECT {{ columns_csv }}
FROM {{ source_relation }}

UNION ALL

-- Krok 2: Wiersze w źródle, których nie ma (lub są inne) w modelu
SELECT {{ columns_csv }}
FROM {{ source_relation }}
EXCEPT
SELECT {{ columns_csv }}
FROM {{ target_relation }}