from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime, timedelta

# Domyślne argumenty dla zadań w DAG-u
default_args = {
    'owner': 'data_engineer',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

# Definicja DAG-a
with DAG(
    dag_id='load_bronze_layer',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily', # Uruchamiaj raz dziennie
    catchup=False,              # Nie nadrabiaj zaległych uruchomień z przeszłości
    tags=['bronze', 'ingestion'],
    description='Ładuje surowe pliki CSV do warstwy Bronze w PostgreSQL'
) as dag:

    # Zadanie wywołujące Twoją procedurę PL/pgSQL
    load_bronze_procedure = SQLExecuteQueryOperator(
        task_id='call_load_bronze_procedure',
        conn_id='postgres_dwh',  # Zbieżne z nazwą połączenia w Airflow
        sql="CALL bronze.load_bronze();",
        autocommit=True          # Wymagane dla niektórych operacji proceduralnych
    )

    # Tutaj w przyszłości dodasz kolejne zadania (np. dbt, Great Expectations)
    # load_bronze_procedure >> dbt_run_silver
