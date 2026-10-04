import logging
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator


# Definicja funkcji przechwytującej błędy (Callback)
def log_failure(context):
    """
    Funkcja wywoływana automatycznie, gdy dowolne zadanie w DAG-u
    zakończy się statusem FAILED.
    """
    task_id = context.get('task_instance').task_id
    execution_date = context.get('execution_date')
    exception = context.get('exception')

    logger = logging.getLogger("airflow.task")

    error_msg = f"""
    ====================================================
    🚨 ALARM 🚨
    Zadanie: {task_id}
    Data logiczna: {execution_date}
    Błąd: {str(exception)}
    ====================================================
    """

    logger.error(error_msg)


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
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    # schedule_interval='@daily',
    schedule=None,
    catchup=False,
    tags=['silver', 'dbt'],
    description='Zasila tabele warstwy Silver na podstawie tabel warstwy Bronze'
) as dag:

    # 2.5 Zrzuty dbt (Snapshots dla tabel SCD2)
    run_dbt_snapshots = BashOperator(
        task_id='dbt_run_silver_snapshots',
        bash_command=(
            "export DBT_PROFILES_DIR=/opt/airflow/dbt_project && "
            "/opt/airflow/dbt_venv/bin/dbt snapshot "
            "--project-dir /opt/airflow/dbt_project"
        ),
    )

    # 3. Transformacja dbt (Bronze -> Silver)
    run_dbt_silver = BashOperator(
        task_id='dbt_run_silver_models',
        bash_command=(
            "export DBT_PROFILES_DIR=/opt/airflow/dbt_project && "
            "/opt/airflow/dbt_venv/bin/dbt run "
            "--project-dir /opt/airflow/dbt_project "
            "--select silver "
        ),
    )

    # 4. Uruchomienie warstwy Gold po sukcesie Silver
    trigger_gold_layer = TriggerDagRunOperator(
        task_id='trigger_gold_layer_dag',
        trigger_dag_id='load_gold_layer',
        wait_for_completion=False,
        reset_dag_run=True
    )

    # Kolejność wykonywania zadań
    dbt_run_silver_snapshots >> run_dbt_silver >> trigger_gold_layer