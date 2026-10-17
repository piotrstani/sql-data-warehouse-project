

    -- Używamy makra dbt do pobrania obiektów kolumn z bazy z relacji źródłowej (compare_to_relation)-- Wyciągamy same nazwy kolumn, omijając te z listy wykluczeń-- Filtr case-insensitive-- Filtr case-insensitive-- Filtr case-insensitive-- Filtr case-insensitive-- Łączymy nazwy w jeden ciąg znaków oddzielony przecinkami-- Krok 1: Wiersze w modelu bazowym, których nie ma (lub są inne) w relacji porównywanej
    SELECT id, cat, subcat
    FROM "DataWarehouse"."bronze"."erp_px_cat_g1v2"
    EXCEPT
    SELECT id, cat, subcat
    FROM "DataWarehouse"."silver"."erp_px_cat_g1v2"

    UNION ALL

    -- Krok 2: Wiersze w relacji porównywanej, których nie ma (lub są inne) w modelu bazowym
    SELECT id, cat, subcat
    FROM "DataWarehouse"."silver"."erp_px_cat_g1v2"
    EXCEPT
    SELECT id, cat, subcat
    FROM "DataWarehouse"."bronze"."erp_px_cat_g1v2"

