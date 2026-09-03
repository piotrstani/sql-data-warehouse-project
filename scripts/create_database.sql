-- Usuń bazę, jeśli istnieje
DROP DATABASE IF EXISTS "training_db";

-- Utwórz bazę
CREATE DATABASE "DataWarehouse";

-- Sprawdz bazy
SELECT datname FROM pg_database;


CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;