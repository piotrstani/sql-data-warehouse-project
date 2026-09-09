import os

from dotenv import load_dotenv
import great_expectations as gx

load_dotenv()

CONN_DATABASE = 'DataWarehouse'
#CONN_DATABASE = os.environ['POSTGRES_DB']

connection_string = (
    f"postgresql+psycopg2://"
    f"{os.environ['POSTGRES_USER']}:"
    f"{os.environ['POSTGRES_PASSWORD']}@"
    f"{os.environ.get('POSTGRES_HOST', 'localhost')}:"
    f"{os.environ.get('POSTGRES_PORT', '5432')}/"
    f"{CONN_DATABASE}"
)

# 1. Inicjalizacja GX
context = gx.get_context()



# 2. Dodanie PostgreSQL jako Data Source
datasource = context.data_sources.add_postgres(
    name="DataWarehouse",
    connection_string=connection_string,
)

print(f"\ncrm_cust_info----------------------------------------------------------------------------------------------")

# 3. Dodanie tabeli jako Data Asset
asset_crm_cust_info = datasource.add_table_asset(
    name="crm_cust_info",
    table_name="crm_cust_info",
    schema_name="bronze",
)

# 4. Utworzenie Batch Definition
batch_definition_crm_cust_info = asset_crm_cust_info.add_batch_definition_whole_table(
    name="crm_cust_info_whole_table"
)

# 5. Pobranie Batch
batch_crm_cust_info = batch_definition_crm_cust_info.get_batch()


# 6. Utworzenie Expectation

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

# Expectation Suite
suite_crm_cust_info = gx.ExpectationSuite(
    name="crm_cust_info_suite"
)

# Dodanie Expectations do Suite
suite_crm_cust_info.add_expectation(expectation_crm_cust_info_cst_id_not_null)
suite_crm_cust_info.add_expectation(expectation_crm_cust_info_cst_id_unique)

# Zapisanie Suite
context.suites.add(suite_crm_cust_info)

# Validation Definition
validation_definition_cust_info = gx.ValidationDefinition(
    name="crm_cust_info_validation",
    data=batch_definition_crm_cust_info,
    suite=suite_crm_cust_info,
)

results_cust_info = validation_definition_cust_info.run()

print(results_cust_info)


print(f"\ncrm_prd_info----------------------------------------------------------------------------------------------")
asset_crm_prd_info = datasource.add_table_asset(
    name="crm_prd_info",
    table_name="crm_prd_info",
    schema_name="bronze",
)

# 4. Utworzenie Batch Definition
batch_definition_crm_prd_info= asset_crm_prd_info.add_batch_definition_whole_table(
    name="crm_prd_info_table"
)

# 5. Pobranie Batch
batch_crm_prd_info_table = batch_definition_crm_prd_info.get_batch()

# 6. Utworzenie Expectation
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


# Dodanie Expectations do Suite
suite_crm_prd_info_prd.add_expectation(expectation_crm_prd_info_prd_id_not_null)

# Zapisanie Suite
context.suites.add(suite_crm_prd_info_prd)

# Validation Definition
validation_definition_crm_prd_info = gx.ValidationDefinition(
    name="crm_prd_info_validation",
    data=batch_definition_crm_prd_info,
    suite=suite_crm_prd_info_prd,
)

# Jedna walidacja całego Suite
results_crm_prd_info = validation_definition_crm_prd_info.run()

print(results_crm_prd_info)

