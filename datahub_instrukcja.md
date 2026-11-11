# DataHub — instrukcja 

**Projekt:** `sql-data-warehouse-project`  
**System:** lokalny Linux + Docker Compose  
**DataHub:** v1.8.0, lokalny Quickstart  
**Baza katalogowana:** PostgreSQL 18 (`DataWarehouse`) używana przez **dbt Core**, nie przez eksperymentalny dbt Fusion.

> **Zakres dokumentu:** 
> trzy etapy:
>  - uruchomienie DataHub,
>  - import fizycznych metadanych PostgreSQL 
>  - integracja dbt Core **wraz z column-level lineage (CLL)**. 
> 
> **Status weryfikacji:** potwierdzono działanie DataHub, zgodność obiektów PostgreSQL i dbt (*siblings*) oraz rzeczywisty CLL między kolumnami.


**Ściąga: co robić i kiedy?**

| Czynność | Kiedy? |
|---|---|
| Pobranie `docker-compose.datahub.yml` i konfiguracja `.env.datahub` | **Jednorazowo** podczas wdrożenia; później tylko przy świadomej aktualizacji konfiguracji/wersji |
| Utworzenie `datahub/ingestion/postgres.yml` | **Jednorazowo**; edycja tylko przy zmianie bazy, zakresu schematów itp. |
| Utworzenie `datahub/ingestion/dbt.yml` | **Jednorazowo**; edycja tylko przy zmianie konfiguracji importu dbt |
| `docker compose ... up -d` | **W razie potrzeby** po zatrzymaniu usług lub uruchomieniu komputera (jeżeli nie startują automatycznie) |
| Kontrola GMS/UI | **Po uruchomieniu** DataHub lub przy diagnostyce |
| Wpisanie hasła przez `read -rsp` | **Przy każdym ręcznym imporcie w nowej sesji terminala** (lub po `unset`) |
| `docker run ... ingest -c /workspace/postgres.yml` | **Powtarzalnie** po zmianie fizycznej struktury PostgreSQL |
| `dbt docs generate` w kontenerze Airflow (Core) | **Powtarzalnie** po zmianach modeli, źródeł, opisów i testów |
| `docker run ... ingest -c /workspace/dbt.yml` (wraz z CLL) | **Powtarzalnie** po odświeżeniu artefaktów dbt Core |
| `unset DATAHUB_PG_PASSWORD` | **Po każdym ręcznym imporcie** |

O ile nie zaznaczono inaczej, polecenia wykonuj na **hoście Linux**, w głównym katalogu repozytorium:

```bash
cd ~/PycharmProjects/sql-data-warehouse-project
```

## Etap 1 — instalacja i uruchomienie DataHub

### 1.1. Jednorazowo — przygotuj plik Compose

Pobrano oficjalną konfigurację Quickstart, zachowując ją w repozytorium jako `docker-compose.datahub.yml`:

```bash
curl -fL \
  https://raw.githubusercontent.com/datahub-project/datahub/v1.8.0/docker/quickstart/docker-compose.quickstart-profile.yml \
  -o docker-compose.datahub.yml
```

**Po co:** dostarcza konfigurację GMS, frontend, MySQL, Kafka, OpenSearch oraz zadania inicjalizacyjnego. Nie trzeba ręcznie tworzyć wszystkich usług. **Nie pobieraj ponownie pliku podczas zwykłego restartu** — nadpisałbyś lokalne dostosowania.

### 1.2. Jednorazowo — ustaw parametry w `.env.datahub`

Wykorzystaliśmy oddzielny plik zmiennych, niezależny od `.env` obsługującego Airflow i PostgreSQL:

```bash
cat > .env.datahub <<EOF2
DATAHUB_VERSION=v1.8.0
DATAHUB_MAPPED_FRONTEND_PORT=9003
DATAHUB_MAPPED_GMS_PORT=58080
UI_INGESTION_DEFAULT_CLI_VERSION=1.7.0.14
DATAHUB_TOKEN_SERVICE_SIGNING_KEY=$(openssl rand -hex 32)
DATAHUB_TOKEN_SERVICE_SALT=$(openssl rand -hex 32)
EOF2
chmod 600 .env.datahub
```

To **wzór na pierwsze utworzenie**, nie uruchamiaj ponownie `cat > .env.datahub`, jeśli plik już istnieje — zmiana sekretów może unieważnić tokeny.

Ważne porty na **hoście**:

| System | Port | Adres |
|---|---:|---|
| Airflow | 8080 | `http://localhost:8080` |
| PostgreSQL dbt Core | 5432 (przyjęte mapowanie) | `localhost:5432` |
| PostgreSQL dbt Fusion | 5433 | `localhost:5433` |
| DataHub Frontend | **9003** | `http://localhost:9003` |
| DataHub GMS | **58080** | `http://localhost:58080` |

Port frontendu zmieniono z domyślnego **9002** na **9003**, ponieważ 9002 był zajęty. Port GMS przeniesiono z 8080 na 58080, aby nie kolidować z Airflow.

**Bezpieczeństwo:** w lokalnym Compose ograniczyliśmy publikowane porty do `127.0.0.1`. Ustawienie to jest częścią dostosowanego pliku Compose — zweryfikuj, że nadal obowiązuje po każdej zmianie pliku. Nie publikuj `.env.datahub` w Git; upewnij się, że obejmuje go `.gitignore` (np. `.env.*`).

### 1.3. Jednorazowo — sprawdź konfigurację

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart config --services
```

`--env-file` wczytuje zmienne; `-f` wybiera własny Compose; `--profile quickstart` aktywuje usługi Quickstart. Sprawdzenie listy usług nie uruchamia kontenerów.

Dodatkowo sprawdź mapowanie portów w pełnej konfiguracji:

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart config
```

### 1.4. Powtarzalnie — uruchom lub wznów DataHub

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart up -d
```

`up -d` uruchamia lub odtwarza brakujące kontenery w tle. Przy kolejnych uruchomieniach **nie pobiera ponownie obrazów, jeśli nie jest to konieczne**. Dane DataHub są przechowywane w wolumenach Docker.

### 1.5. Powtarzalnie — sprawdź stan

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart ps -a

curl -s -o /dev/null -w 'HTTP: %{http_code}\n' \
  http://localhost:58080/health
```

Oczekujemy `HTTP: 200` oraz działającego UI pod `http://localhost:9003`. Dla zadania `system-update-quickstart` status `Exited (0)` jest prawidłowy — to zadanie inicjalizacyjne. W tej instalacji **oba warunki potwierdzono**.

W razie problemów:

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart \
  logs --tail=100 datahub-gms-quickstart frontend-quickstart
```

### 1.6. Powtarzalnie — zatrzymanie bez utraty metadanych

```bash
docker compose --env-file .env.datahub \
  -f docker-compose.datahub.yml --profile quickstart down
```

**Nie używaj `down -v`** przy zwykłym zatrzymaniu: `-v` usuwa wolumeny, a razem z nimi dane lokalnego DataHub.

## Etap 2 — import metadanych PostgreSQL 18 do DataHub

### 2.1. Jednorazowo — przygotuj katalog i recipe

```bash
mkdir -p datahub/ingestion
```

Plik `datahub/ingestion/postgres.yml`:

```yaml
source:
  type: postgres
  config:
    host_port: "127.0.0.1:5432"
    database: "DataWarehouse"
    convert_urns_to_lowercase: false

    username: "dwh_user1"
    password: "${DATAHUB_PG_PASSWORD}"

    env: DEV

    include_tables: true
    include_views: true

    schema_pattern:
      allow:
        - "^bronze$"
        - "^silver$"
        - "^gold$"

    profiling:
      enabled: false

sink:
  type: datahub-rest
  config:
    server: "http://127.0.0.1:58080"
```

>Konektor `postgres` odczytuje metadane fizycznej bazy, takie jak schematy, tabele, widoki i kolumny, a `datahub-rest` wysyła je do API GMS.

>`schema_pattern` ogranicza katalog do Bronze/Silver/Gold; `profiling.enabled: false` wyłącza analizę zawartości/statystyk danych. 

>Ustawienie `env: DEV` klasyfikuje zasoby jako deweloperskie — w następnym etapie zachowaj tę samą nazwę środowiska dla dbt.

>Ustawienie krytyczne: `convert_urns_to_lowercase: false`. Baza fizyczna nazywa się dokładnie `DataWarehouse`. 
>Jeśli importer dbt utworzy odwołania do `datawarehouse` (małymi literami), DataHub potraktuje je jako **inne URN**, co może wytworzyć puste / niepełne obiekty PostgreSQL (*shell entities*). 
>W obu plikach recipe zachowujemy wielkość liter nazw bazy. 

### 2.2. Powtarzalnie — podaj hasło bez wyświetlania

```bash
read -rsp "Hasło PostgreSQL (dwh_user1): " DATAHUB_PG_PASSWORD
echo
export DATAHUB_PG_PASSWORD
```

Wpisywanie nie pokazuje znaków. `export` udostępnia wartość kontenerowi uruchomionemu przez `docker run`; wpis nie trafia do recipe ani Git.

### 2.3. Powtarzalnie — uruchom importer metadanych

```bash
docker run --rm \
  --network host \
  -v "$PWD/datahub/ingestion:/workspace:ro" \
  -e DATAHUB_PG_PASSWORD \
  acryldata/datahub-ingestion:v1.8.0-slim \
  ingest -c /workspace/postgres.yml
```

Co robi polecenie:

- `docker run` uruchamia **tymczasowy** proces importu; nie jest to stała usługa serwera.
- `--rm` usuwa kontener po zakończeniu, nie usuwa metadanych zapisanych w DataHub.
- `--network host` (lokalny Linux) umożliwia połączenie z PostgreSQL `localhost:5432` i GMS `localhost:58080`; mniej konfiguracji sieci, lecz mniejsza izolacja sieciowa.
- `-v ...:ro` udostępnia plik `postgres.yml` tylko do odczytu.
- `-e ...` przekazuje sekret z bieżącego terminala.
- `v1.8.0-slim` jest przypiętą wersją obrazu zawierającą konektor PostgreSQL.
- `ingest -c ...` uruchamia jednorazowy odczyt i zapis metadanych.

Po imporcie:

```bash
unset DATAHUB_PG_PASSWORD
```

**Wcześniej potwierdzony wynik:** fizyczne zasoby PostgreSQL były widoczne razem z logicznymi zasobami dbt, a poprawny obiekt `DataWarehouse.gold.dim_customers` miał schemat kolumn i był powiązany z dbt. Po każdym ponownym imporcie sprawdź status importera i metadane w UI.

### 2.4. Powtarzalnie — sprawdź wynik w interfejsie

Otwórz `http://localhost:9003` i wyszukaj `crm_cust_info`, `erp_loc_a101`, `dim_customers`. Powinny być widoczne zasoby platformy PostgreSQL oraz ich schematy i kolumny. Jeżeli ich nie ma, sprawdź, czy importer łączył się z **Core**, a nie z Fusion, i czy użytkownik ma dostęp do metadanych.

## Etap 3 — integracja dbt Core i jego artefaktów w tym column-level lineage
### 3.1. Powtarzalnie — wygeneruj artefakty w dbt Core

**Wykonaj w kontenerze Airflow, w którym działa dbt Core 1.12.5**, nie w kontenerze dbt Fusion:

```bash
cd /opt/airflow/dbt_project

dbt --version
dbt docs generate
ls -lh target/manifest.json target/catalog.json
```

- `manifest.json` zawiera definicje węzłów projektu: źródła, modele, seed, snapshoty, testy, dokumentację YAML, zależności `ref()` i `source()` oraz skompilowany SQL, o ile został wygenerowany.
- `catalog.json` zawiera informacje o faktycznych relacjach i kolumnach z PostgreSQL. Uzupełnia dane z manifestu.

>Same definicje testów w `manifest.json` **nie oznaczają zaimportowanych wyników ich wykonania**. 
>- Do wyników służy oddzielny artefakt `run_results.json`; jego import nie jest objęty tą instrukcją.


Na hoście Linux sprawdź dostępność tych samych plików przez montowanie projektu do Airflow:

```bash
cd ~/PycharmProjects/sql-data-warehouse-project
ls -lh dbt_project/target/manifest.json dbt_project/target/catalog.json
```

Nie commituj zawartości `dbt_project/target/` — to artefakty lokalne. Nie uruchamiaj ponownie `dbt build` tylko po to, aby odświeżyć katalog.

### 3.2. Jednorazowo — skonfiguruj pełny import dbt z CLL

Docelowy plik `datahub/ingestion/dbt.yml` (konfiguracja, dla której potwierdzono działający CLL):

```yaml
source:
  type: dbt
  config:
    manifest_path: /dbt/target/manifest.json
    catalog_path: /dbt/target/catalog.json

    target_platform: postgres
    env: DEV

    platform_instance: data_warehouse
    convert_urns_to_lowercase: false

    include_database_name: true
    include_compiled_code: true
    infer_dbt_schemas: true
    include_column_lineage: true

sink:
  type: datahub-rest
  config:
    server: "http://127.0.0.1:58080"
```

**Znaczenie parametrów krytycznych:**

| Parametr | Rola |
|---|---|
| `target_platform: postgres` | Łączy logiczne obiekty dbt z platformą fizyczną PostgreSQL. |
| `env: DEV` | Musi zgadzać się ze środowiskiem w importerze PostgreSQL. |
| `platform_instance: data_warehouse` | Identyfikuje **projekt/instancję dbt** i tworzy jego przestrzeń nazw, nie nazwę fizycznej bazy. |
| `convert_urns_to_lowercase: false` | **Konieczne:** zachowuje dokładną pisownię `DataWarehouse` w odwołaniach dbt do PostgreSQL. |
| `include_database_name: true` | Umieszcza nazwę bazy `DataWarehouse` w identyfikatorach docelowych relacji. |
| `include_compiled_code: true` | Umożliwia przeglądanie skompilowanego SQL modelu. |
| `infer_dbt_schemas: true` | Pomaga przypisać węzłom dbt właściwe schematy i nazwy fizycznych relacji. |
| `include_column_lineage: true` | Uruchamia wyznaczanie zależności między kolumnami na podstawie skompilowanego SQL. |

**Nie dodawaj `target_platform_instance`** w tej konfiguracji: importer PostgreSQL nie używa `platform_instance`. Samo `platform_instance: data_warehouse` w dbt pozostaje potrzebne.

### 3.3. Powtarzalnie — zaimportuj metadane dbt i column-level lineage

**Na hoście Linux**, w katalogu repozytorium, po imporcie PostgreSQL z etapu 2:

```bash
docker run --rm \
  --network host \
  -v "$PWD/datahub/ingestion:/workspace:ro" \
  -v "$PWD/dbt_project/target:/dbt/target:ro" \
  acryldata/datahub-ingestion:v1.8.0-slim \
  ingest -c /workspace/dbt.yml
```

- Kontener importera jest tymczasowy (`--rm`); DataHub pozostaje uruchomiony w swoim Compose.
- Pierwsze montowanie `:ro` udostępnia recipe, drugie — `manifest.json` i `catalog.json`.
- Import dbt nie wymaga hasła PostgreSQL: działa na wygenerowanych plikach JSON i przesyła metadane do GMS.
- Po każdej zmianie modeli / SQL / dokumentacji wygeneruj świeże artefakty **przed** uruchomieniem importera.

**Przykład kontroli raportu importu:** sukces procesu oraz pojawienie się aspektów `fineGrainedLineages` świadczą o wygenerowanych zależnościach kolumnowych. Wcześniejszy raport zawierał `fineGrainedLineages: 16`, `sql_parser_column_errors: 0` oraz `sql_parser_table_errors: 1` związany z operacją hooka `CREATE SCHEMA IF NOT EXISTS audit` (`on-run-start`), nie ze zwykłym modelem transformacji. Liczbę linii i ostrzeżeń po każdym nowym imporcie oceniaj z jego własnego raportu.

### 3.4. Powtarzalnie — zweryfikuj poprawne URN i powiązania
W interfejsie `http://localhost:9003` sprawdź kolejno:

1. Fizyczny dataset PostgreSQL `DataWarehouse.gold.dim_customers` ma kolumny i typy, a nie pustą zakładkę **Columns**.
2. Model dbt `gold.dim_customers` ma opis, definicję SQL (*View Definition*) i prawidłowe powiązanie **sibling / Composed Of** z fizycznym PostgreSQL.
3. W **Lineage** widoczne są zależności na poziomie modeli (**model-level lineage**) oraz na poziomie kolumn (**column-level lineage**), np. `silver.erp_cust_az12.bdate → gold.dim_customers.birthdate`.
4. Nazwy `DataWarehouse` są zapisane z prawidłową wielkością liter; nie pojawiają się niepełne zasoby fizyczne `postgres.datawarehouse.*` powstałe z błędnych odwołań.

**Ważne przy interpretacji nawigatora:**

- Pod platformą **PostgreSQL** oczekiwana jest baza `DataWarehouse` oraz schematy `bronze`, `silver`, `gold`.
- Pod platformą **dbt** nadrzędny kontener `datawarehouse` może zawierać właściwy kontener `DataWarehouse`. Ten **poziom nadrzędny jest prawidłową organizacją katalogu**, nie dowodem duplikacji obiektów.
- Węzły `dbt Source`, `dbt Model` i fizyczne obiekty PostgreSQL to różne rodzaje metadanych. Ich wspólna obecność na grafie nie jest błędem, o ile URN fizycznego datasetu, sibling i lineage wskazują właściwe relacje.

### 3.5. Zakres metadanych — co faktycznie osiągnięto

W projekcie zidentyfikowano **17 logicznych zasobów dbt**: 6 źródeł Bronze, 8 zasobów Silver (6 modeli, 1 seed, 1 snapshot) i 3 modele Gold. Dodatkowo manifest zawierał definicje testów, a część modeli korzystała z kontraktów dbt. Poniżej rozróżnienie metadanych od wyników wykonania:

| Element | W tym etapie |
|---|---|
| Źródła, modele, seed, snapshot | Importowane z artefaktów dbt |
| Opisy YAML modeli i kolumn | Importowane z manifestu |
| Definicje SQL / skompilowany kod modeli | Importowane przy `include_compiled_code: true` |
| Zależności między modelami / źródłami | Importowane (model-level lineage) |
| Zależności między kolumnami | Importowane przy `include_column_lineage: true`, zweryfikowane w UI |
| Definicje testów i konfiguracja kontraktów w dbt | Obecne w metadanych manifestu; **nie oznacza automatycznie** osobnej prezentacji wszystkich szczegółów w DataHub |
| Wyniki uruchomienia testów (`run_results.json`) | **Poza zakresem tej instrukcji**; nie były potwierdzonym wynikiem tego importu |

### 3.6. Jak często odświeżać katalog?

| Zmiana w projekcie | Co ponowić? |
|---|---|
| Fizyczny schemat PostgreSQL: nowa tabela, widok, kolumna lub typ | Import PostgreSQL (etap 2.2–2.4); następnie odśwież artefakty i import dbt (etap 3.1–3.4), jeśli modele też się zmieniły |
| SQL modeli, `ref()`, `source()`, dokumentacja YAML, definicje testów | `dbt docs generate` i ponowny import dbt (etap 3.1, 3.3, 3.4) |
| Wyłącznie nowe rekordy bez zmiany schematu | Zwykle bez importu (profilowanie wyłączone) |
| Restart DataHub / hosta | Etap 1.4–1.5; **nie** instalacja od nowa |

>#### **Import PostgreSQL i dbt można docelowo zautomatyzować w Airflow.**

## 3.7 Uproszczenia zastosowane w tym projekcie

1. **Oficjalny Quickstart w osobnym Compose** zamiast produkcyjnego klastra: szybciej i łatwiej wersjonować w Git; Quickstart nie jest konfiguracją produkcyjną (domyślne konta, ograniczona odporność).
2. **Różne porty na hoście:** `9003` dla UI (bo 9002 było zajęte), `58080` dla GMS (bo Airflow korzysta z 8080). Porty wewnętrzne DataHub pozostają bez zmian.
3. **Tymczasowy importer Docker** zamiast instalacji DataHub CLI na hoście i dedykowanej usługi w Compose: mniej zależności, a katalog działa niezależnie od chwilowego procesu importu.
4. **`--network host`** zamiast wspólnej sieci dla kilku Compose: wygodne na Linuxie, ale docelowo warto rozdzielić sieci i dostępy.
5. **Bez profilowania i bez skanowania całej instancji:** katalogujemy tylko `bronze`, `silver`, `gold`, nie zbieramy wartości ani statystyk z tabel.

### 3.8. Źródła i dokumentacja

- DataHub Quickstart: https://docs.datahub.com/docs/quickstart/
- Konektor PostgreSQL: https://docs.datahub.com/docs/generated/ingestion/sources/postgres
- Konektor dbt: https://docs.datahub.com/docs/generated/ingestion/sources/dbt
- DataHub CLI i ingestion: https://docs.datahub.com/docs/metadata-ingestion/cli-ingestion/
- Oficjalne obrazy Dockera: https://github.com/datahub-project/datahub/blob/master/docker/README.md
