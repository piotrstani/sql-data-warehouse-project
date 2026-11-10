# dbt Fusion — eksperyment na PostgreSQL

> **Status: eksperyment, 8 listopada 2026 r.** Projekt produkcyjny/deweloperski pozostaje na 
> **dbt Core 1.12.5** w kontenerze Airflow. Kopia `dbt_project_fusion/` jest uruchamiana osobno na
> **dbt Fusion 2.0.11** z **eksperymentalnym adapterem PostgreSQL**. Nie zastępuje jeszcze dbt Core.

## Architektura testu

- `dbt_project/` — oryginalny projekt dbt Core, uruchamiany przez Airflow.
- `dbt_project_fusion/` — osobna kopia modeli, źródeł, snapshotów, makr i testów, dostosowywana wyłącznie do Fusion.
- `docker-compose.fusion.yml` — oddzielny stos Docker, **jeżeli ten plik jest dodany do repozytorium**. Usługi: `postgres_fusion` i `dbt_fusion`; baza PostgreSQL ma własny wolumen `postgres_fusion_data`.
- `docker/dbt-fusion/Dockerfile` — obraz z CLI dbt Fusion instalowanym z oficjalnego instalatora.
- PostgreSQL Core: domyślnie `localhost:5432`; PostgreSQL Fusion: `127.0.0.1:5433` → port `5432` wewnątrz kontenera. W sieci Compose Fusion łączy się z `postgres_fusion:5432`.
- `postgres_admin` zarządza testową bazą, zaś `dwh_user1` (zmienne `FUSION_DBT_USER` / `FUSION_DBT_PASSWORD`) wykonuje transformacje. Sprawdź faktyczne nazwy kont w swoim `.env`.


### Zmiany w projekcie Fusion

1. Dla eksperymentalnego adaptera PostgreSQL dodano obejście makra `postgres__get_columns_in_relation`, które korzysta z `information_schema.columns` zamiast niepoprawnego `DataWarehouse.INFORMATION_SCHEMA.columns` (plik w `dbt_project_fusion/macros/`).
2. W `dbt_project_fusion/dbt_project.yml` ustawiono `+persist_docs: {relation: true, columns: false}` dla odpowiednich modeli, ponieważ zbiorcze `COMMENT ON COLUMN` powodowało błąd przygotowanego zapytania.
3. Usunięto błędy referencji/deprecacji i formatowania YAML wykryte przez `dbt parse` w toku eksperymentu.
4. 
Te obejścia dotyczą **tylko testowej kopii Fusion** i mogą przestać być potrzebne po wydaniu obsługi PostgreSQL.

## Uruchomienie

### Oddzielny stos Fusion
```bash
docker compose -f docker-compose.fusion.yml up -d --build
docker compose -f docker-compose.fusion.yml ps
```
### Polecenia Docker wykonuj **na hoście w katalogu głównym repozytorium**, a polecenia `dbt` — **wewnątrz kontenera `sql-data-warehouse-fusion-dbt_fusion-1`**.

### W konfiguracji usługi `postgres_fusion` port dla DBeaver może być wystawiony tylko lokalnie:
```yaml
ports:
  - "127.0.0.1:5433:5432"
```

### Przygotuj testową bazę

Fusion wymaga własnej instancji PostgreSQL i tabel źródłowych Bronze. Jeżeli baza jest pusta, skopiuj ją **jednorazowo** z głównego PostgreSQL (poniższe polecenia tworzą lokalny dump zawierający dane):

```bash
docker exec sql-data-warehouse-postgres \
  sh -lc 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' \
  > fusion_seed.dump

docker compose -f docker-compose.fusion.yml exec -T postgres_fusion \
  sh -lc 'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --no-owner --no-acl' \
  < fusion_seed.dump

rm fusion_seed.dump
```

**Uwaga:** `pg_restore --no-owner` może pozostawić odtworzone obiekty jako własność `postgres_admin`. 
Rola `dwh_user1` musi istnieć w **testowym** PostgreSQL. 
Jeśli jej nie ma, połącz się do testowej bazy jako administrator i nadaj wymagane uprawnienia:

### Uruchom polecenia dbt Fusion

```bash
docker compose -f docker-compose.fusion.yml exec dbt_fusion bash
```

W kontenerze dbt_fusion (`/app/dbt_project`):

```bash
dbt --version
dbt deps
dbt debug --profiles-dir .
dbt parse --profiles-dir .
dbt build --select erp_loc_a101 --profiles-dir .
```

## STATUS
Pełny `dbt build` **nadal nie jest potwierdzony jako działający**, ponieważ wykryto awarię adaptera podczas analizy metadanych. 
Do próby z pominięciem testów jednostkowych:

```bash
dbt build --exclude-resource-type unit_test --profiles-dir .
```

## Aktualny stan i rozpoznane problemy

| Obszar | Stan / komunikat | Co zrobiono lub co pozostaje |
|---|---|---|
| Dostęp do PostgreSQL i schematów | **OK po korekcie** | Wcześniejsze `permission denied for schema audit` i `_test_failures` rozwiązano przez konfigurację uprawnień/ownership. |
| Modele `table`, `view`, `incremental` | **Częściowo potwierdzone** | W logach wykonały się m.in. `erp_loc_a101`, `crm_sales_details`, `v_crm_prd_info`; modele Gold wymagają pełnego przebiegu bez awarii. |
| Snapshot i seed | **OK w wykonanych próbach** | `crm_prd_info` (snapshot) i `seed_full_moon_dates` zakończyły się sukcesem. |
| Metadane kolumn | **Obejście** | `cross-database references are not implemented: "DataWarehouse.information_schema.columns"` → lokalne nadpisanie makra PostgreSQL. |
| Zapisywanie opisów kolumn | **Obejście** | `cannot insert multiple commands into a prepared statement` przy wielu `COMMENT ON COLUMN` → `persist_docs.columns: false`. Opisy pozostają w YAML. |
| PRIMARY KEY | **Ostrzeżenie** | `ConstraintNotEnforced (dbt1109)` — adapter zgłasza brak gwarancji egzekwowania PK. Należy oddzielnie sprawdzić faktyczne ograniczenia w `pg_constraint`; nie wyłączaj ostrzeżenia w ciemno. |
| Testy danych | **Działają, część WARN** | `unique`, `not_null`, testy relacji i dbt-expectations wykonywały się. WARN w źródłach i relacjach wymagają analizy danych, nie są tym samym co awaria adaptera. |
| Pełny `dbt build` | **NIEPOTWIERDZONY / awaria silnika** | `panic: not yet implemented: PostgreSQL's list_relations_schemas` w adapterze Rust. Wystąpił w fazie analizy po uruchomieniu większości zasobów. |
| Unit tests | **Podejrzewane źródło panic** | Podczas pełnego `build` był test jednostkowy `test_gndr_dim_customers`. Warto sprawdzić `--exclude-resource-type unit_test`; sam `panic` nie dowodzi jednak, że jest to jedyna ścieżka wywołania błędnej funkcji. |
| Docs v2 / column-level lineage | **ZABLOKOWANE** | `dbt compile --generate-info-schema --static-analysis strict` wywołuje ten sam `panic` na `list_relations_schemas`. Brak wygenerowanych metadanych może ukrywać widok Column-level Lineage w Docs v2. |


#### **Nie uzyskano końcowego raportu zakończonego sukcesem**, ponieważ proces zakończył się awarią adaptera Rust.
#### **Główna blokada migracji:**
- nieukończona implementacja **PostgreSQL `list_relations_schemas`** w Fusion 2.0.11.

## Rollback / zakończenie eksperymentu
Na hoście:

```bash
docker compose -f docker-compose.fusion.yml down
```
Polecenie zatrzymuje środowisko testowe bez usuwania wolumenu. 
**Nie używaj `down -v`**, jeśli chcesz zachować testową bazę. 
Oryginalny Airflow, dbt Core i PostgreSQL działają niezależnie; nie wymagają odtwarzania ani ponownej instalacji. 
Testowy `dbt_project_fusion/` nie jest wykorzystywany przez dotychczasowe DAG-i.


## Źródła

- [dbt Fusion — dokumentacja](https://docs.getdbt.com/docs/fusion)
- [dbt Docs v2 i metadata lineage](https://docs.getdbt.com/reference/commands/cmd-docs?version=2)
- [dbt — testy jednostkowe i wykluczanie z build](https://docs.getdbt.com/docs/build/unit-tests?version=2)
