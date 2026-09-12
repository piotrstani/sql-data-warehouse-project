
/*
DataWarehouse bedzie w docker compose

-- Usuń bazę, jeśli istnieje
DROP DATABASE IF EXISTS "DataWarehouse";
-- Utwórz bazę
CREATE DATABASE "DataWarehouse";
*/
-- Sprawdz bazy
SELECT datname FROM pg_database;
