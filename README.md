
Oparty na kontenerach projekt hurtowni danych. Airflow jako orkiestrator procesu ETL (Python) i walidacji (Great Expectations) przed zapisaniem czystych danych w architekturze Medallion na PostgreSQL.

1. **DB**:PostgreSQL
	 - [x] docker container
2. **BRONZE Layer**
	 - [x] 'pandas source analytics'
	 - [x] ddl
   **Data Ingestion**: plpgsql/Python
     - [x] plpgsql procedure
     - [x] Python container
     - [x] Airflow Ingestion COPY 
     - [ ] TODDO pyspark over-enginering
4. **SILVER Layer**
	 - [x] ddl
     - [ ] DAG dbt snpashot
     - [ ] DAG dbt test
     - [ ] DAG dbt docs ?
     - [x] dbt
       - [x] crm_cust_info
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] crm_prd_info SCD FULL, /snapshots/crm_prd_info.sql      
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] crm_sales_details FACT
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] erp_cust_az12
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] erp_loc_a101
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] erp_px_cat_g1v2
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
4. **GOLD Layer**
	 - [x] sql views with description
     - [x] data markt diagram
     - [x] dbt create view, /models/gold/dim_customers.sql + /macros/generate_schema_name.sql
     - [x] dbt
       - [x] dim_customers
         - [x] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [x] dbt docs
       - [x] dim_products
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
       - [x] fact_sales
         - [ ] dbt description 
         - [ ] dbt tests
         - [ ] dbt contracts
         - [ ] dbt docs
5. **DQ**:
     - dbt
     - [x] Docker dla dbt -- as aditional install pip dbt-postgres
       - [x] testy: 
         - customer_id NOT NULL,  
         - customer_id UNIQUE,
         - FK (relationships)
	 - Great Expectations
       - [x] localhost
       - [x] bronze Ingestion Dane [!] dane przepuszczane przez warstwę Bronze, czyszczenie na warstwie Silver za pomocą dbt
       - [x] logowanie na Airflow jako warrinning 
       - [x] wynik GE kopiowana z Airflow do docs/gx/run_ts_airflow_id [!]777 aby pychram mógł usuwać
       - [ ] zaawansowane kontrole
                - czy liczba rekordów nie spadła nagle o 80%? ---dbt genric
                - czy dane są wystarczająco świeże?  
                - czy schema nie zmieniła się niespodziewanie? ---dbt schema / contracts 
       
6. **Airflow**
 - [x] Airflow conteiner --as standalone
 - [x] Airflow config 
 - [ ] DAG bronze plpgsql (CALL bronze.load_bronze()) 
      - [ ] #TODO osobne zadania truncate_tables, load_crm_cust_info, ...  Lista tabel i równoległe zadania (Dynamic Task Mapping)
      - [!] RAISE NOTICE - nie logowany do interfejsu Airflow, werfikacja w logach bazy danych
      - [!] przy fail **Retry** uruchomi to zadanie ponownie,
      - **Baza danych tylko liczy i przechowuje, a orkiestrator (Airflow) zarządza czasem, logiką i logowaniem**
 - [x] DAG bronze great_expectations
 - [x] DAG silver dbt 

**Docelowa architektura**:
```
                         ┌──────────────────────┐
                         │       AIRFLOW        │
                         │──────────────────────│
                         │     orchestration    │
                         └──────────┬───────────┘
                                    │
                ┌───────────────────────────────────┐
                │                                   │
                ▼                                   ▼
        ┌──────────────┐                    ┌────────────────┐
        │    PYTHON    │                    │      DBT       │
        │────pandas────│                    │────────────────│
        │analysis      │                    │transform       │
        │visualization │                    │pipeline testing│
        │──────GX──────│                    │docs            │ 
        │observability │                    │lineage         │  
        │advanced DQ   │                    │                │             
        └──────┬───────┘                    └───────┬────────┘
               │                                    │
               └───────────────────┬────────────────┘
                                   ▼
                         ┌──────────────────┐
                         │    POSTGRESQL    │
                         │──────────────────│
                         │     Bronze       │
                         │       ↓          │
                         │     Silver       │
                         │       ↓          │
                         │      Gold        │
                         └──────────────────┘
```
---

|Komponent|Odpowiedzialność|
|---|---|
|PostgreSQL|Storage|
|~~PostgreSQL/ingestion~~|~~`COPY`CSV → Bronze~~|
|Airflow/Python/ingestion|CALL bronze.load_bronze()|
|PySpark|TODO|
|~~PostgreSQL/Transformacje~~|~~Load Silver~~|
|dbt|Transformacje + standardowe testy + dokumentacja + lineage (Silver,Gold)|
|Python + GX|analiza + zaawansowana kontrola jakości + obserwowalność|
|Airflow|Orkiestracja|
|PyCharm|development|



