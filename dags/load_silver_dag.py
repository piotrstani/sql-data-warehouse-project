import logging
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

#------------------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------------------

# Domyślne argumenty dla zadań w DAG-u
default_args = {
    'owner': 'data_engineer',
    'retries': 0,
    'retry_delay': timedelta(minutes=2),
    'on_failure_callback': log_failure,
}


# Definicja DAG-a
with DAG(
    dag_id='load_silver_layer',
    default_args={
        "owner": "data_engineer",
        "retries": 0,
        "retry_delay": timedelta(minutes=2),
        "on_failure_callback": log_failure,
    },
    start_date=datetime(2024, 1, 1),
    # schedule_interval='@daily',
    schedule=None,
    catchup=False,
    tags=["silver", "dbt", "quality"],
    description="Bronze -> Silver: snapshot, modele, testy jakości, następnie Gold"
) as dag:

#------------------------------------------------------------------------------------------
    #1. Snapshots dla tabel SCD2 (model v_crm_prd_info zależy od snapshotu)
    run_dbt_snapshots = BashOperator(
        task_id='dbt_run_silver_snapshots',
        bash_command=dbt_bash("snapshot"),
    )

    #2. Zbudowanie wszystkich modeli z katalogu models/silver
    run_dbt_silver = BashOperator(
        task_id='dbt_run_silver_models',
        bash_command=dbt_bash('run --select "silver"'),
    )

    #3. Testy jako osobny krok. 'buildable' ogranicza testy do wybranej
    # warstwy i jej zależności wstecznych, bez testów wymagających Gold.
    test_dbt_silver = BashOperator(
        task_id="dbt_test_silver_models",
        bash_command=dbt_bash(
            'test --select "silver" --indirect-selection=buildable'
        ),
    )
#------------------------------------------------------------------------------------------

    # 4. Domyślna reguła Airflow: all_success. Gold uruchomi się tylko wtedy,
    # gdy transformacje i testy zakończą się powodzeniem.
    trigger_gold_layer = TriggerDagRunOperator(
        task_id='trigger_gold_layer_dag',
        trigger_dag_id='load_gold_layer',
        wait_for_completion=False,
        reset_dag_run=True
    )

    # Kolejność wykonywania zadań
    run_dbt_snapshots >> run_dbt_silver >> test_dbt_silver >> trigger_gold_layer