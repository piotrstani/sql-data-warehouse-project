-- Test sprawdza logikę chronologiczną dat.
-- Wyłapuje zamówienia wysłane przed ich złożeniem lub złożone po terminie.

select *
from {{ ref('fact_sales') }}
where
    order_date > shipping_date  -- ANOMALIA: data wysyłki przed datą zamówienia
    or order_date = due_dt      -- ANOMALIA: data zamówienia po dacie wymagalności
LIMIT 1000