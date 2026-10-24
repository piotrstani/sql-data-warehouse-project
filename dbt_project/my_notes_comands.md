
### DEBUG
- warehouse connection
- `dbt debug`
---

- what models dbt see
- `dbt ls`

---
### PARSING
- validate YAML
- `dbt parse`

---
### COMPILE
- render Jinja to SQL, on dbt fusion also checks SQL syntax
- `dbt complie`
- `dbt compile --inline 'SELECT * from {{ ref("crm_cust_info") }} WHERE {{ no_empty_strings(ref("crm_cust_info")) }}'`

---
### CLEAN _CLEAN TARGET AND PACKAGES FOLDER_
- def in dbt_project.yml : clean-targets: ["target", "dbt_packages"]
- `dbt clean`

---
### DOCS
- `dbt docs generate`

---
### DEPS
- packages.yml
- `dbt deps`

---
### SHOW
- `dbt show -s crm_prd_info`
```
19:20:13  Running with dbt=1.12.5
19:20:13  Registered adapter: postgres=1.11.0
19:20:14  Found 8 models, 1 snapshot, 1 analysis, 20 data tests, 1 seed, 3 operations, 12 sources, 920 macros, 1 unit test
19:20:14
19:20:14  Concurrency: 4 threads (target='dev')
19:20:14
Previewing node 'crm_prd_info':
| prd_id | cat_id | prd_key | prd_nm               | prd_cost | prd_line    | ... |
| ------ | ------ | ------- | -------------------- | -------- | ----------- | --- |
|    478 | AC_BC  | BC-M005 | Mountain Bottle Cage |        4 | Moutain     | ... |
|    479 | AC_BC  | BC-R205 | Road Bottle Cage     |        3 | Road        | ... |
|    477 | AC_BC  | WB-H098 | Water Bottle - 30... |        2 | Other Sales | ... |
|    483 | AC_BR  | RA-H123 | Hitch Rack - 4-Bike  |       45 | Other Sales | ... |
```

---
### BUILD
- Jeśli test modelu nadrzędnego zawiedzie, dbt automatycznie pomija (SKIP) budowę modeli zależnych.
- dbt seed + dbt run + dbt snapshot + dbt test
- Harmonogramy produkcyjne (Airflow), potoki CI/CD i bezpieczne wdrażanie danych.
- `dbt build -s crm_cust_info`

---
### RUN 
- materializuje ale to szybkie deweloperskie iteracje i przebudowa logiki SQL
- `dbt run -s crm_cust_info`

- run with limit 0
- `dbt run --empty`

- <time expression>  działa względem kolumny event_time którą trzeba wskazać na config modelu
- `dbt run --sample <time expression>`
- `dbt run -s crm_cust_info --sample "3 days"`

---
### RUN ONLY MACRO
- `dbt run-operation learn_log`

---
### RUN BY TAG
- START sql incremental model silver.crm_sales_details
- `dbt_project$ dbt run -s tags:fact`

---
### RUN VARS
- inremental tab
- `dbt run -s crm_sales_details --vars '{"start_date":"2014-01-01","end_date":"2014-12-31"}'`

---
### RUN WITH SELECTORS / DAG FILTER
- +model downstream modelu
- 1+model downstream modelu 1 poziom w dół
-model+ upstream modelu
- @model downstream + upstream modelu
- `dbt run -s crm_sales_details+`

---
### SNAPSHOT SCD2 BY TAG
- START snapshot silver.crm_prd_info
- `dbt snapshot -s tag:scd2`


---
# TEST

- `dbt test --select source:bronze`
- `dbt test -s crm_cust_info`

---
### TEST BY TAG
- `dbt test -s source:bronze.ela,tag:tests2`
- `dbt test -s tag:all`
- `dbt test -s tag:tst3`

---
### TEST WITH VARS
- `dbt test -s source:bronze.test_crm_cust_info --vars '{"table_id": "_info"}'`

- `TABLE_ID="_info" dbt test -s source:bronze.test_crm_cust_info`
- `TABLE_ID="_info" dbt test -s tag:tst1`
```
export TABLE_ID="_info"
dbt test -s source:bronze.test_crm_cust_info
```

---
### TEST WITH PATHS
- `dbt test -s path:sources/bronze_test/crm_sales_details.yml`
- `dbt test -s path:sources/bronze_test/crm_cust_info.yml --vars '{"table_id": "_info"}'`

---
### FRESHNESS
`dbt source freshness -s path:sources/bronze_freshness_tests`

---
### RETRY
- retry zasobów które zakończyły się błędem (ERROR) lub zostały pominięte (SKIP), komenda  automatycznie odczytuje stan z pliku run_results.json w folderze target/
- `dbt retry`

---
# Slim CI
- Zamiast każdorazowo budować całą hurtownię od zera przy wprowadzaniu zmian używamy stanu i odroczeń, by procesować tylko to, co absolutnie konieczne
- określanie diff pomiędzy schematami dev i prod

- `dbt build --target dev --state target-prod --select state:modified+`
- `dbt defer`  .. jw  logicznie przekierowanie ref() na produkcje,  odpytanie danych bezpośrednio ze schematu produkcyjnego dla tabel do budowy model docelowego
- `dbt clone` ... jw  Google BigQuery opiera się na natywnej funkcji Table Clones (tzw. Zero-Copy Cloning)