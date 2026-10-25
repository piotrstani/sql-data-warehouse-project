# 🏗️ SQL Data Warehouse Project

[![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Apache Airflow](https://img.shields.io/badge/Airflow-017CEE?style=for-the-badge&logo=Apache%20Airflow&logoColor=white)](https://airflow.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

 
## Witaj w moim repozytorium! 

**To mój osobisty poligon doświadczalny i projekt szkoleniowy**, którego głównym celem jest praktyczne poznanie nowoczesnego stosu technologicznego inżynierii danych oraz eksperymentowanie z narzędziami takimi jak dbt, Airflow czy Docker.

- Projekt analitycznej hurtowni danych zbudowanej w oparciu o architekturę **Medallion** (Bronze, Silver, Gold)
- Logika transformacji i testowania danych została zaimplementowana za pomocą **dbt (Data Build Tool)** działającego na silniku **PostgreSQL**
- Całość procesów (ETL/ELT) orkiestrowana jest przy użyciu **Apache Airflow** w skonteneryzowanym środowisku **Docker**
- Szczególny nacisk w projekcie położono na **Data Observability & Quality** z użyciem **dbt (Data Build Tool)**

**Gorąco zapraszam do dyskusji** – jeśli widzisz miejsce na optymalizację, masz pomysł na lepsze podejście do danego problemu lub chcesz wytknąć błąd architektoniczny, otwórz _Issue_ lub zostaw komentarz. 


---
## 🎓 Inspiracje i Źródła Wiedzy

Architektura i najlepsze praktyki wdrożone w tym projekcie są fuzją wynikającą z połączania następujących szkoleń:

*   [Building a Modern Data Warehouse - Data Engineering Bootcamp](https://www.udemy.com/course/building-a-modern-data-warehouse-data-engineering-bootcamp)
*   [Complete dbt (Data Build Tool) Bootcamp: Zero to Hero](https://www.udemy.com/course/complete-dbt-data-build-tool-bootcamp-zero-to-hero-learn-dbt)


---
## 🎯 Główne założenia i badane koncepcje

Podczas pracy nad tym projektem skupiam się na implementacji i testowaniu następujących koncepcji:

- **Architektura Medallion:**
	Organizacja przepływu danych w warstwach 
	🥉 **Bronze** (Surowe dane pobierane z systemów źródłowych)
	🥈 **Silver** (Dane ustandaryzowane i oczyszczone)
	🥇 **Gold** (Gotowe fakty i wymiary zoptymalizowane pod kątem raportowania i analizy)    
- **Data Observability & Quality:** 
	Eksperymentowanie z frameworkiem testowym dbt:
	- świeżości danych, 
	- walidację mechanizmów SCD2 
	- zaawansowane biznesowe testy singularne
- **Orkiestracja:** 
	- Budowanie DAG-ów w Apache Airflow do zarządzania cyklem życia modeli dbt.

---
## 🚧 Świadome uproszczenia i skróty (Trade-offs)

Ponieważ jest to projekt edukacyjny, celowo zastosowałem w nim pewne skróty, które w komercyjnym środowisku produkcyjnym wymagałyby zmiany:

1. **Lokalna infrastruktura:** Używam PostgreSQL postawionego w Dockerze jako głównej hurtowni danych.  
2. **Statyczne dane:** Dane źródłowe dla **Bronze** są statycznymi plikami w katalogu `datasets/`.  
3. **Brak zaawansowanego CI/CD:** Obecnie projekt nie posiada w pełni zautomatyzowanych pipeline. Airflow w trybie `standalone`: wszystkie komponenty Webserver, Scheduler i baza SQLite wewnątrz jednego kontenera. 
4. **Użyto dbt Core**, które jest zaszyte wewnątrz kontenera Airflow.
5. **Zarządzanie sekretami (Security):** Dane dostępowe są przechowywane w prostych plikach `.env`    
6. **Role i uprawnienia (RBAC):** Uproszczone zarządzanie dostępem do bazy danych i interfejsu Airflow.
---

## 📂 Struktura Projektu

```text
sql-data-warehouse-project/
├── dags/                       # Skrypty orkiestracji (DAGi Apache Airflow)
├── datasets/                   # Statyczne pliki z danymi źródłowymi (CSV)
├── dbt_project/                # Główny katalog projektu Data Build Tool
│   ├── models/                 # Modele transformacji SQL (bronze, silver, gold)
│   │   ├── bronze/
│   │   ├── silver/
│   │   └── gold/
│   ├── sources/                # Deklaracje źródeł zewnętrznych (YAML)
│   │   ├── bronze              # Deklaracje źródeł dla modeli transformacji
│   │   ├── bronze_freshness_tests/  # TBD Deklaracje modeli jako źródeł testowych (dbt jako repozytorium testów)
│   │   ├── silver_mirror_tests/     # jw
│   │   ├── bronze_freshness_tests/  # jw
│   │   ├── gold_biz_tests           # jw
│   │   └── silver_scd2_tests/       # jw
│   ├── tests/                  # Testy singularne
│   │   └── gold_biz_tests/     # TBD Reguły walidacji logiki biznesowej (dbt jako repozytorium testów)
│   ├── dbt_project.yml         # Konfiguracja projektu dbt
│   └── packages.yml            # Zależności dbt (dbt-utils, dbt-expectations)
├── docker/                     # Pliki Dockerfile i konfiguracje obrazów (np. niestandardowy Airflow)
├── docs/                       # Dodatkowa dokumentacja projektowa i notatki architektoniczne
├── scripts/                    # Skrypty pomocnicze (np. bash/python do inicjalizacji bazy)
├── tools/                      # Konfiguracje zewnętrznych narzędzi wspierających
├── .env.example                # Szablon zmiennych środowiskowych (do skopiowania jako .env)
├── docker-compose.yml          # Konfiguracja całego środowiska lokalnego
└── README.md                   # Ten plik
```


---

## 🚀 Uruchomienie lokalne

###  🛠️ Kroki startowe:
Jeśli chcesz pobawić się tym projektem u siebie, postępuj zgodnie z poniższymi krokami. Całość opiera się na kontenerach, więc nie musisz instalować bazy ani Airflow bezpośrednio na swoim systemie.
##### Krok 1: Sklonuj repozytorium
```bash
git clone https://github.com/piotrstani/sql-data-warehouse-project.git
cd sql-data-warehouse-project
```
##### Krok 2: Skonfiguruj środowisko
Skopiuj plik z przykładowymi zmiennymi. To z niego Postgres, Airflow i dbt pobiorą spójne hasła do komunikacj.
```bash
cp .env.example .env
```
##### Krok 3: Uruchom środowisko Docker
```bash
docker-compose up -d
```
##### Krok 4: Wystartuj bazę danych PostgreSQL oraz usługę orkiestracji Airflow+dbt
```bash
docker start sql-data-warehouse-postgres 
docker start sql-data-warehouse-airflow 
```

---
### 🐘 Konfiguracja PostgreSQL 

Hurtownia danych działa jako lokalny kontener. Ustawienia dostępowe (użytkownik, hasło, nazwa bazy) pobierane są z pliku `.env`. Port `5432` jest domyślnie zmapowany na hosta,co pozwala na łatwe podpięcie Twojego ulubionego klienta SQL (np. DBeaver, DataGrip) i bezpośrednie eksplorowanie tabel

Jako `admin`:
1. Utwórz bazę: `scripts/create_database.sql`
2. Utwórz schematy: `scripts/create_schemas.sql`
3. Nadaj uprawnienia dla `dwh_user`: `scripts/create_user_add_privileges.sql`

---
### 🌪️ Konfiguracja Airflow 

Airflow orkiestruje cały proces. Zmienne z pliku `.env` służą do inicjalizacji konta administratora (UI dostępne pod `localhost:8080`). 
Katalogi `dags/` oraz `dbt_project/` są zmapowane (mounted) jako wolumeny bezpośrednio do kontenera. Dzięki temu każda zmiana, którą wprowadzisz w kodzie (zarówno w skryptach Pythona, jak i modelach dbt), jest widoczna natychmiast – bez konieczności przebudowywania obrazów Dockera.

##### Krok 1: Pozyskanie hasła do Airflow

- **OPCJA 1: Podejrzenie hasła z logów**
Tryb `standalone` automatycznie generuje użytkownika o loginie `admin`, ale losuje mu hasło ze względów bezpieczeństwa. Aby je odczytać, sprawdź logi nowego kontenera:
```Bash
docker logs sql-data-warehouse-airflow | grep password
```
Powinieneś zobaczyć linijkę typu: `Airflow standalone is for development purposes only... password: <losowy_ciąg_znaków>`

- **OPCJA 2: **Usunięcie konta `admin` i utworzenie go ponownie z hasłem (zawsze działa)**
Komunikat `admin already exist in the db` oznacza, że mechanizm `standalone` zdążył jednak utworzyć to konto w tle, ale hasło przepadło gdzieś w gąszczu logów (lub zostało nadpisane przez inne procesy startowe).

1. Usuń istniejące konto `admin`:
    ```Bash
    docker exec -it sql-data-warehouse-airflow airflow users delete -u admin
    ```
    
2. Utwórz je ponownie z hasłem `admin`:
    ```Bash
    docker exec -it sql-data-warehouse-airflow airflow users create \
      --username admin \
      --firstname Data \
      --lastname Engineer \
      --role Admin \
      --email admin@example.com \
      --password admin
    ```
  
3. Wejdź w przeglądarkę i wpisz adres: **`http://localhost:8080`**  
4. Zaloguj się używając: `admin` / `admin`

##### Krok 2: Zestawienie połączenia (Connection)

1. W górnym menu Airflow kliknij **Admin** ➡️ **Connections**.   
2. Kliknij niebieski przycisk z plusem **(+)**, aby dodać nowe połączenie. 
3. Skonfiguruj je następująco:  
    - **Connection Id:** `postgres_dwh` _(to musi być identyczne co do litery z wartością `conn_id` w kodzie  DAG-a)_
    - **Connection Type:** `Postgres` 
    - **Host:** `postgres` _(nazwa kontenera z docker-compose)_ 
    - **Database:** `DataWarehouse`  
    - **Login:** `dwh_user1` _(zgodnie `.env`)_  
    - **Password:** _(zgodnie  `.env`)_   
    - **Port:** `5432` 
4. Zapisz (przycisk **Save**).

##### Krok 3: Pierwsze wywołanie (Trigger)

1. Na zakładce **DAGs** (ikona domku), odszukać DAG np: `load_bronze_layer`
2. Odblokować go (niebieski przełącznik po lewej stronie z "Pause" na "Unpause")
3. Wcisnąć przycisk **"Play"** (Trigger DAG) po prawej 


---
### 🟠 Konfiguracja dbt 

Środowisko **dbt Core** jest już zaszyte wewnątrz kontenera Airflow. 
Połączenie dbt z bazą danych (docelowy target: `dev`) skonfigurowane jest w pliku `profiles.yml`. 
Hasła i nazwy schematów nie są wpisane na sztywno – dbt zaczytuje je w locie jako zmienne środowiskowe przekazane do kontenera.

1. Wejdź w interaktywną powłokę kontenera, w którym zainstalowane jest dbt
```bash
docker exec -it sql-data-warehouse-airflow bash
cd dbt_project
```
2. Pobierz zależności dbt
```bash
dbt deps
```
3. Zbuduj i przetestuj całą hurtownię danych
```bash
dbt build
```


**📂 Najważniejsze katalogi w projekcie:**
* `models/` – tu znajdują się skrypty SQL (z elementami języka Jinja), które dbt zamienia na tabele i widoki w bazie. Są one podzielone na warstwy architektury Medallion (`bronze/`, `silver/`, `gold/`).
* `sources/` – Miejsce na pliki YAML z deklaracjami danych źródłowych (tzw. Sources). To tutaj definiujesz zewnętrzne tabele, z których dbt jedynie pobiera dane (np. dla warstwy Bronze), oraz ustawiasz dla nich progi testów świeżości (Source Freshness) i podstawowe testy generyczne.
* `tests/` – Miejsce na testy singularne (własne skrypty SQL walidujące logikę biznesową). Każdy zapytanie, które zwróci jakikolwiek wiersz z tego katalogu, oznacza anomalię (błąd).
* `target/` – Katalog tymczasowy (zignorowany w Git): skompilowany, czysty kod SQL (bez znaczników Jinja), który faktycznie trafia do bazy danych, wygenerowane pliki dokumentacji. Kluczowe miejsce do debugowania.
* `dbt_packages/` – Folder pobranych bibliotek zewnętrznych (np. `dbt_utils`, `dbt_expectations`). 

**⚡ Dbt Cheatsheet (Najprzydatniejsze komendy):**
* `dbt deps` – Instaluje zewnętrzne pakiety zdefiniowane w `packages.yml`. Zawsze uruchamiaj na start.
* `dbt build` – Komenda ostateczna. Uruchamia cały projekt w odpowiedniej kolejności: ładuje pliki statyczne (seed), buduje modele, wykonuje testy i snapshoty. Jeśli test jakiegoś modelu nie przejdzie, dbt automatycznie przerwie budowanie modeli, które od niego zależą.
* `dbt run` – Uruchamia wyłącznie transformacje (buduje tabele/widoki). Ignoruje testy.
* `dbt test` – Wykonuje tylko zdefiniowane testy generyczne (z plików YAML) i singularne (z plików SQL).
* `dbt compile` – Zamienia kod Jinja na czysty SQL i zapisuje go w folderze `target/`, ale **nie wysyła** go do bazy danych. Idealne do sprawdzania, co dokładnie dbt chce wykonać.
* `dbt docs generate` – Analizuje projekt, odpytuje bazę o metadane i generuje pełną, interaktywną dokumentację.

 **📊 Dokumentacja i podgląd Lineage Graph:**

Środowisko posiada zintegrowaną, interaktywną dokumentację dbt (dbt docs), która wizualizuje graf zależności (DAG) pomiędzy tabelami z różnych warstw, a także przypięte do nich testy generyczne i singularne.

#OBECNIE
Stycznie poprzez wywołanie `dbt docs generate` a następnie otworzenie w przeglądarce: `dbt_project/target/index.html`

#TODO Dokumentacja w przeglądarce pod adresem: `http://localhost:8080` 
```bash
dbt docs generate
dbt docs serve --port 8080 --host 0.0.0.0
```

---
## 👤 Autor

**Piotr Stani**
*   GitHub: [@piotrstani](https://github.com/piotrstani)
---