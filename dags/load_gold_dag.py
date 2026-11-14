import logging
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator # Nowy import

DBT_PROJECT_DIR = "/opt/airflow/dbt_project"

# Definicja funkcji przechwytującej błędy (Callback)
def log_failure(context):

    """Zapisz szczegóły błędu zadania do logów Airflow."""
    task_id = context.get('task_instance').task_id
    logging.getLogger("airflow.task").error(
        "DAG load_silver_layer: task=%s, logical_date=%s, error=%s",
        task_id.task_id if task_id else "unknown",
        context.get("logical_date"),
        context.get("exception"),
    )

def dbt_bash(command):
    """Jednolite środowisko wykonania wszystkich poleceń dbt Core."""
    return (
        "set -euo pipefail\n"
        f'cd "{DBT_PROJECT_DIR}"\n'
        f'export DBT_PROFILES_DIR="{DBT_PROJECT_DIR}"\n'
        f'dbt {command} --project-dir "{DBT_PROJECT_DIR}"\n'
    )

# Domyślne argumenty dla zadań w DAG-u, nadpisywane w definicjami DAG-ów
default_args = {
    'owner': 'data_engineer',
    'retries': 0,
    'retry_delay': timedelta(minutes=2),
    'on_failure_callback': log_failure,  # <-- Przypinamy nasz system alertów do wszystkich zadań
}

# Definicja DAG-a
with DAG(
        dag_id='load_gold_layer',
        default_args={
            "owner": "data_engineer",
            "retries": 0,
            "retry_delay": timedelta(minutes=2),
            "on_failure_callback": log_failure,
        },
        start_date=datetime(2024, 1, 1),
        #schedule_interval='@daily', # Uruchamiaj raz dziennie
        schedule=None,
        catchup=False, # Nie nadrabiaj zaległych uruchomień z przeszłości
        tags=["silver", "dbt", "quality"],
        description="Silver -> Gold:  modele, testy jakości"
) as dag:

    # ------------------------------------------------------------------------------------------

    # 1. Zbudowanie wszystkich modeli z katalogu models/silver
    run_dbt_gold = BashOperator(
        task_id='dbt_run_gold_models',
        bash_command=dbt_bash('run --select "gold"'),
    )

    # 3. Testy jako osobny krok. 'buildable' ogranicza testy do wybranej
    # warstwy i jej zależności wstecznych, bez testów wymagających Gold.
    test_dbt_gold = BashOperator(
        task_id="dbt_test_gold_models",
        bash_command=dbt_bash(
            'test --select "gold" --indirect-selection=buildable'
        ),
    )
    # ------------------------------------------------------------------------------------------

    # Kolejność wykonywania zadań
    run_dbt_gold >> test_dbt_gold