/*
dwh_user: szkoleniowo  jeden user z HIGHER do wszystkiego

docelowo:
airflow_user: airflow ingestion_user
dbt_user: dbt transform_user
python_user:  python analytics_user
 */


/*----------------------------LOW-----------------------------------------------
--user
CREATE USER dwh_user1 WITH PASSWORD 'user1_password';

--databse
-- Tylko prawo do połączenia z bazą (zamiast ALL PRIVILEGES ON DATABASE)
GRANT CONNECT ON DATABASE "DataWarehouse" TO dwh_user1;
--schema
-- Prawo do używania schematu
GRANT USAGE ON SCHEMA bronze TO dwh_user1;

--tables
-- Precyzyjne prawa do operacji na danych (bez CREATE i DROP)
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA bronze TO dwh_user1;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA bronze TO dwh_user1;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA bronze TO dwh_user1;

-- To samo dla nowo tworzonych tabel w przyszłości
ALTER DEFAULT PRIVILEGES IN SCHEMA bronze
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO dwh_user1;

--read from server
GRANT pg_read_server_files TO dwh_user1;
--GRANT pg_write_server_files TO dwh_user1;
----------------------------LOW---------------------------------------------------*/

----------------------------HIGHER------------------------------------------------
--ALTER USER moj_user WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "DataWarehouse" TO dwh_user1;

--databse
GRANT ALL PRIVILEGES ON SCHEMA bronze TO dwh_user1;

--schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA bronze TO dwh_user1;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA bronze TO dwh_user1;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA bronze TO dwh_user1;

--tables
ALTER DEFAULT PRIVILEGES IN SCHEMA bronze
GRANT ALL PRIVILEGES ON TABLES TO dwh_user1;

ALTER DEFAULT PRIVILEGES IN SCHEMA bronze
GRANT ALL PRIVILEGES ON SEQUENCES TO dwh_user1;

ALTER DEFAULT PRIVILEGES IN SCHEMA bronze
GRANT ALL PRIVILEGES ON FUNCTIONS TO dwh_user1;

-----------------------------------------------------------------------------------*/