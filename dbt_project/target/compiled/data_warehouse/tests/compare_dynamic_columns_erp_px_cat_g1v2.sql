---erp_px_cat_g1v2 brak transformacij



-- 1. Zdefiniuj listę kolumn, które chcesz pominąć w porównaniu (np. techniczne timestampy)


-- Używamy makra dbt do pobrania obiektów kolumn z bazy-- Wyciągamy same nazwy kolumn, omijając te z listy wykluczeń-- Filtr case-insensitive: zamieniamy nazwy na małe litery, by uniknąć problemów z wielkością znaków-- Filtr case-insensitive: zamieniamy nazwy na małe litery, by uniknąć problemów z wielkością znaków-- Filtr case-insensitive: zamieniamy nazwy na małe litery, by uniknąć problemów z wielkością znaków-- Filtr case-insensitive: zamieniamy nazwy na małe litery, by uniknąć problemów z wielkością znaków-- Krok 1: Wiersze w modelu, których nie ma (lub są inne) w źródle
SELECT id, cat, subcat
FROM "DataWarehouse"."silver"."erp_px_cat_g1v2"
EXCEPT
SELECT id, cat, subcat
FROM "DataWarehouse"."bronze"."erp_px_cat_g1v2"

UNION ALL

-- Krok 2: Wiersze w źródle, których nie ma (lub są inne) w modelu
SELECT id, cat, subcat
FROM "DataWarehouse"."bronze"."erp_px_cat_g1v2"
EXCEPT
SELECT id, cat, subcat
FROM "DataWarehouse"."silver"."erp_px_cat_g1v2"