import os
import shutil #do kopiowania plików
from datetime import datetime
from dotenv import load_dotenv
import great_expectations as gx

load_dotenv()

#-------------------------------------------------------------CONNECTION
#CONN_DATABASE = 'DataWarehouse'
CONN_DATABASE = os.environ['POSTGRES_DB']

connection_string = (
    f"postgresql+psycopg2://"
    f"{os.environ['POSTGRES_USER']}:"
    f"{os.environ['POSTGRES_PASSWORD']}@"
    f"{os.environ.get('POSTGRES_HOST', 'postgres')}:"
    f"{os.environ.get('POSTGRES_PORT', '5432')}/"
    f"{CONN_DATABASE}"
)

#Inicjalizacja GX
context = gx.get_context()

#-------------------------------------------------------------SOURCE
#Dodanie PostgreSQL jako Data Source
datasource = context.data_sources.add_postgres(
    name="DataWarehouse",
    connection_string=connection_string,
)

#----------------------------------------------------------------------------------------------------------crm_cust_info

#-------------------------------------------------------------ASSET
#Dodanie tabeli jako Data Asset
asset_crm_cust_info = datasource.add_table_asset(
    name="crm_cust_info",
    table_name="crm_cust_info",
    schema_name="bronze",
)

#--------------------------------------------------------------BATCH
#Utworzenie Batch Definition
batch_definition_crm_cust_info = asset_crm_cust_info.add_batch_definition_whole_table(
    name="crm_cust_info_whole_table"
)
#Pobranie Batch
batch_crm_cust_info = batch_definition_crm_cust_info.get_batch()

#-------------------------------------------------------------EXPECTATION
# Expectation not_null
expectation_crm_cust_info_cst_id_not_null = gx.expectations.ExpectColumnValuesToNotBeNull(
    column="cst_id",
    severity= "critical", #info,warning, critical
    meta={
        "description": "Customer ID cannot be NULL"
    }
)

# Expectation unique
expectation_crm_cust_info_cst_id_unique = gx.expectations.ExpectColumnValuesToBeUnique(
    column="cst_id",
    severity="warning",  # info,warning, critical
    meta={
        "description": "Customer ID should be UNIQUE"
    }
)

#-------------------------------------------------------------SUITE
# Expectation Suite
suite_crm_cust_info = gx.ExpectationSuite(
    name="crm_cust_info_suite"
)

# Dodanie Expectations do Suite
suite_crm_cust_info.add_expectation(expectation_crm_cust_info_cst_id_not_null)
suite_crm_cust_info.add_expectation(expectation_crm_cust_info_cst_id_unique)

# Zapisanie Suite
context.suites.add(suite_crm_cust_info)

#-------------------------------------------------------------VALIDATION
# Dodanie Validation Definition
validation_definition_cust_info = context.validation_definitions.add(
    gx.ValidationDefinition(
        name="crm_cust_info_validation",
        data=batch_definition_crm_cust_info,
        suite=suite_crm_cust_info,
    )
)

#----------------------------------------------------------------------------------------------------------crm_cust_info
#----------------------------------------------------------------------------------------------------------crm_prd_info

asset_crm_prd_info = datasource.add_table_asset(
    name="crm_prd_info",
    table_name="crm_prd_info",
    schema_name="bronze",
)

batch_definition_crm_prd_info= asset_crm_prd_info.add_batch_definition_whole_table(
    name="crm_prd_info_table"
)

batch_crm_prd_info_table = batch_definition_crm_prd_info.get_batch()

expectation_crm_prd_info_prd_id_not_null = gx.expectations.ExpectColumnValuesToNotBeNull(
    column="prd_id",
    severity= "info", #info,warning, critical
    meta={
        "description": "Product ID is NULL"
    }
)

suite_crm_prd_info_prd= gx.ExpectationSuite(
    name="crm_prd_info_suite"
)

suite_crm_prd_info_prd.add_expectation(expectation_crm_prd_info_prd_id_not_null)

context.suites.add(suite_crm_prd_info_prd)

validation_definition_crm_prd_info = context.validation_definitions.add(
    gx.ValidationDefinition(
        name="crm_prd_info_validation",
        data=batch_definition_crm_prd_info,
        suite=suite_crm_prd_info_prd,
    )
)
#----------------------------------------------------------------------------------------------------------crm_prd_info


#---------------------------------------------------------------------------------------------CHECKPOINT
# Utworzenie Checkpoint
checkpoint_bronze = gx.Checkpoint(
    name="bronze_data_quality",
    validation_definitions=[
        validation_definition_cust_info,
        validation_definition_crm_prd_info,
    ],
)

#Dodanei Checkpoint do context
context.checkpoints.add(checkpoint_bronze)

#---------------------------------------------------------------------------------------------RESULT
results_bronze = checkpoint_bronze.run()
print(results_bronze)

#Budowanie Data Docs i wyciąganie ich z kontenera
print("Budowanie dokumentacji HTML Data Docs...")
site_urls = context.build_data_docs()
local_site_url = site_urls.get("local_site")

if local_site_url:
    # Czyszczenie ścieżki z prefiksu i pobranie ścieżki katalogu
    local_site_path = local_site_url.replace("file://", "")
    site_dir = os.path.dirname(local_site_path)

    # Pobranie run_id ze zmiennych wstrzykniętych przez Airflow
    airflow_run_id = os.environ.get("AIRFLOW_RUN_ID")

    # Generowanie unikalnego podkatalogu: znacznik czasu + 8 znaków losowego ID
    run_timestamp = datetime.now().strftime("%Y%m%d%H%M%S")

    if airflow_run_id:
        # Zamiana niedozwolonych znaków (np. dwukropków z timestampu) na bezpieczne
        safe_run_id = airflow_run_id.replace(":", "").replace("+", "_")
        target_dir = f"/opt/airflow/docs/gx/run_{run_timestamp}_{safe_run_id}"
    else:
        # Fallback (na wypadek testowego, ręcznego uruchomienia skryptu poza Airflow)
        target_dir = f"/opt/airflow/docs/gx/manual_python_run_{run_timestamp}_none"

    # Kopiowanie z /tmp/... do zamontowanego /opt/airflow/docs/gx/run_ts_uuid
    shutil.copytree(site_dir, target_dir, dirs_exist_ok=True)
    #  Nadanie pełnych uprawnień (rwx) dla wygenerowanego katalogu, aby host mógł swobodnie usuwać te pliki.
    os.system(f"chmod -R 777 {target_dir}")
    print(f"✅ Data Docs zostały wyeksportowane do: {target_dir}")

# Weryfikacja sukcesu Checkpointu dla Airflow
if not results_bronze.success:
    print("❌ Błąd walidacji Data Quality na warstwie Bronze!")
    #Rzuca kod błędu, który Airflow zinterpretuje jako "Task Failed"
    # Dane pzrepuszczam przez warstwę Bronze, czyszczenie warstwie Silver za pomocą dbt
    #sys.exit(1)

else:
    print("✅ Wszystkie testy Great Expectations zakończone sukcesem.")