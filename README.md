
Oparty na kontenerach projekt hurtowni danych. Airflow jako orkiestrator procesu ETL (Python) i walidacji (Great Expectations) przed zapisaniem czystych danych w architekturze Medallion na PostgreSQL.

1. **DB**:PostgreSQL
	 - [x] docker container
2. **BRONZE Layer**
	 - [x] 'pandas source analytics'
	 - [x] bronze ddl
3. **Data Ingestion**: plpgsql/Python
	 - [x] plpgsql procedure
	 - [ ] Python container
	 - [ ] Python Ingestion COPY 
4. **DQ**:
     - dbt
     - [ ] SQL transformations (SILVER)   
       - [ ] testy: 
         - customer_id NOT NULL,  
         - customer_id UNIQUE,
         - FK istnieje
       - [ ] Docker dla dbt       
       - [ ] SQL transformations (SILVER)   
       - ❓❓❓
       - [ ] zależności między modelami: relationships ❓
       - [ ] dokumentacja ❓
       - [ ] lineage ❓
	 - Great Expectations
       - [x] localhost
       - [ ] conteiner
       - [ ] zaawansowane kontrole
         - czy liczba rekordów nie spadła nagle o 80%?
         - czy dane są wystarczająco świeże?
         - czy schema nie zmieniła się niespodziewanie?
       
5. **Airflow**

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
|Python / ingestion|Load|
|`COPY`|CSV → Bronze|
|dbt|Transformacje + standardowe testy + dokumentacja + lineage|
|Python + GX|analiza + zaawansowana kontrola jakości + obserwowalność|
|Airflow|Orkiestracja|
|PyCharm|development|



