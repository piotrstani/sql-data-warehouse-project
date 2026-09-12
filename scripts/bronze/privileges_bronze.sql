
/*
SELECT datname
FROM pg_database
ORDER BY datname;

SELECT current_database(),
       current_user,
       inet_server_addr(),
       inet_server_port(),
       version();

SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;
  */

--user
--ALTER USER moj_user WITH SUPERUSER;
CREATE USER dwh_user1 WITH PASSWORD 'user1_password';
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

--read from server
GRANT pg_read_server_files TO dwh_user1;
--GRANT pg_write_server_files TO dwh_user1;