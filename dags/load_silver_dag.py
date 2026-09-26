import logging
from airflow import DAG
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
    'retries': 0,
    'retry_delay': timedelta(minutes=2),
    'on_failure_callback': log_failure,  # <-- Przypinamy nasz system alertów do wszystkich zadań
}

# Definicja DAG-a
with DAG(
    dag_id='load_silver_layer',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    #schedule_interval='@daily', # Uruchamiaj raz dziennie
    schedule=None,
    catchup=False,              # Nie nadrabiaj zaległych uruchomień z przeszłości
    tags=['silver', 'dbt'],
    description='Zasila tabele warstwy Silver na podstawie tabel warstwy Bronze '
) as dag:

    # 3. Transformacja dbt (Bronze -> Silver)
        run_dbt_silver = BashOperator(
        task_id='dbt_run_silver_models',
        bash_command=(
            "export DBT_PROFILES_DIR=/opt/airflow/dbt_project && "
            "/opt/airflow/dbt_venv/bin/dbt run "
            "--project-dir /opt/airflow/dbt_project"
        ),
)