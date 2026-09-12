import os
import pandas as pd
from sqlalchemy import create_engine, text

# Pobieranie zmiennych środowiskowych wstrzykniętych przez Docker Compose
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# SQLAlchemy connection string dla PostgreSQL
engine_url = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(engine_url)


def test_connection():
    try:
        with engine.connect() as conn:
            # 1. Test wersji bazy danych
            result = conn.execute(text("SELECT version();")).scalar()
            print(f"✅ Sukces! Połączono jako {DB_USER} z bazą na serwerze:\n{result}\n")

            # 2. Test odczytu danych z warstwy Bronze
            print(">> Pobieranie 3 losowych wierszy z bronze.crm_cust_info...")
            query = "SELECT * FROM bronze.crm_cust_info LIMIT 3;"
            df = pd.read_sql(query, conn)

            with pd.option_context('display.max_columns', None, 'display.width', 1000):
                print(df)

    except Exception as e:
        print(f"❌ Błąd połączenia lub braku uprawnień: {e}")


if __name__ == "__main__":
    test_connection()