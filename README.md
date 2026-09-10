


1. **DB**:PostgreSQL
	 - [x] docker container
2. **Bronze Layer**
	 - [x] 'pandas source analytics'
	 - [x] bronze ddl
3. **ETL**:plpgsql/Python
	 - [x] plpgsql procedure
	 - [ ] Python container
	 - [ ] Python ETL :sign
4. **DQ**:
	 - Great Expectations
		 - [x] localhost
		 - [ ] conteiner
	 - BDD, Hybrid, PyTest, Allure ❓
	 - dbt	❓
5. **Airflow**

**Architektura**:
```
                    ┌─────────────────────┐
                    │       AIRFLOW       │
                    │                     │
                    │       DAG           │
                    └──────────┬──────────┘
                               │
                    uruchamia zadania
                               │
              ┌────────────────┴────────────────┐
              │                                 │
              ▼                                 ▼
      ┌─────────────────┐              ┌─────────────────┐
      │     PYTHON      │              │     PYTHON      │
      │                 │              │                 │
      │ ETL             │              │ Great           │
      │                 │              │ Expectations    │
      │                 │              │                 │
      └────────┬────────┘              └────────┬────────┘
               │                                │
               │                                │
               └──────────────┬─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │    POSTGRES      │
                    │                  │
                    │  DataWarehouse   │
                    │                  │
                    │ bronze           │
                    │ silver           │
                    │ gold             │
                    └──────────────────┘
```


---
**Docker**
```
                    Docker Compose
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
     PostgreSQL        Python         Airflow
      container       container       container
          │              │              │
          │              │              │
          └──────────────┴──────────────┘
                  Docker network

```

---
**Postgres**
Przechowuje:
```
DataWarehouse
├── bronze
├── silver
└── gold
```

---
**Python**
```
ETL / ELT
  ↓
import danych
  ↓
transformacje  --? 
  ↓
Great Expectations
  ↓
Data Quality
```

---
**Great Expectations**
```
Suite
  ↓
ValidationDefinition
  ↓
context.validation_definitions
  ↓
Checkpoint
  ↓
context.checkpoints
  ↓
run()
```

---
**Airflow**
```
Airflow DAG
   │
   ├── uruchom ETL Python
   │
   ├── czekaj na zakończenie
   │
   ├── uruchom Data Quality
   │
   └── jeśli DQ OK → następny etap
       jeśli DQ FAIL → zatrzymaj DAG
```

