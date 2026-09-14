import logging
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator # Nowy import


# Definicja funkcji przechwytującej błędy (Callback)
def log_failure(context):
    """
    Funkcja wywoływana automatycznie, gdy dowolne zadanie w DAG-u zakończy się statusem FAILED.
    Pobiera kontekst uruchomienia (słownik z metadanymi Airflow).
    """
    task_id = context.get('task_instance').task_id
    execution_date = context.get('execution_date')
    exception = context.get('exception')

    # Inicjalizacja standardowego loggera Pythona
    logger = logging.getLogger("airflow.task")

    # Formatowanie komunikatu błędu
    error_msg = f"""
    ====================================================
    🚨 ALARM 🚨
    Zadanie: {task_id}
    Data logiczna: {execution_date}
    Błąd: {str(exception)}
    ====================================================
    """
    # Wysłanie komunikatu do logów Airflow
    logger.error(error_msg)

    # Na produkcji w tym miejscu umieszcza się kod wysyłający webhook na Slacka/Teams

# Domyślne argumenty dla zadań w DAG-u, nadpisywane w definicjami DAG-ów
default_args = {
    'owner': 'data_engineer',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
    'on_failure_callback': log_failure,  # <-- Przypinamy nasz system alertów do wszystkich zadań
}

# Definicja DAG-a
with DAG(
    dag_id='load_bronze_layer',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily', # Uruchamiaj raz dziennie
    catchup=False,              # Nie nadrabiaj zaległych uruchomień z przeszłości
    tags=['bronze', 'ingestion', 'dq'],
    description='Ładuje surowe pliki CSV do warstwy Bronze w PostgreSQ, wykonuje prosty test GE'
) as dag:

    # 1. Bronze ingestion
    # Zadanie wywołujące Twoją procedurę PL/pgSQL
        load_bronze_procedure = SQLExecuteQueryOperator(
        task_id='call_load_bronze_procedure',
        conn_id='postgres_dwh',  # Zbieżne z nazwą połączenia w Airflow
        sql="CALL bronze.load_bronze();",
        autocommit=True          # Wymagane dla niektórych operacji proceduralnych
    )

    # 2. Test Great Expectations
        run_ge_bronze_tests = BashOperator(
        task_id='run_great_expectations_bronze',
        # Uruchamiamy z głównego katalogu kontenera, gdzie znajduje się plik .env
        bash_command='export AIRFLOW_RUN_ID={{ run_id }} && cd /opt/airflow && python tests/great_expectations/ge_tests_bronze.py',
        retries = 0  # <-- Ten parametr wyłącza Retry tylko dla tego zadania
        )

        # Ustalenie kolejności wykonywania zadań
        load_bronze_procedure >> run_ge_bronze_tests