import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

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

def verify_database_connection(conn_string: str) -> bool:
    engine = None

    try:
        engine = create_engine(conn_string)
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return True

    except SQLAlchemyError as err:
        print(f"[ERROR] Błąd połączenia z bazą danych: {err}")
        return False

    finally:
        if engine is not None:
            engine.dispose()


if verify_database_connection(connection_string):
    print("System gotowy do migracji/importu danych.")
else:
    raise SystemExit(1)