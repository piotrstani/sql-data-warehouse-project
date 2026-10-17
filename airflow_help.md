### Krok 3: Uruchomienie i logowanie

1. W głównym katalogu uruchom ponownie Dockera, aby podniósł nowy kontener: 
    ```Bash
    docker compose up -d
    ```

2. **Jak zdobyć hasło do Airflow?** 
Tryb `standalone` automatycznie generuje użytkownika o loginie `admin`, ale losuje mu hasło ze względów bezpieczeństwa. Aby je odczytać, sprawdź logi nowego kontenera:
```Bash
docker logs sql-data-warehouse-airflow | grep password
```
Powinieneś zobaczyć linijkę typu: `Airflow standalone is for development purposes only... password: <losowy_ciąg_znaków>`
   
- **Usunięcie konta `admin` i utworzenie go ponownie z hasłem, które znasz.**
Komunikat **`admin already exist in the db`** oznacza, że mechanizm `standalone` zdążył jednak utworzyć to konto w tle, ale hasło przepadło gdzieś w gąszczu logów (lub zostało nadpisane przez inne procesy startowe).
- **Usuń istniejące konto `admin`:**
    ```Bash
    docker exec -it sql-data-warehouse-airflow airflow users delete -u admin
    ```
- **Utwórz je ponownie z hasłem `admin`:**
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
4. Zaloguj się używając loginu: `admin` i skopiowanego przed chwilą hasła lub `admin` / `admin`
---
### Krok 4: Zestawienie połączenia (Connection)

1. W górnym menu Airflow kliknij **Admin** ➡️ **Connections**.   
2. Kliknij niebieski przycisk z plusem **(+)**, aby dodać nowe połączenie. 
3. Skonfiguruj je następująco:  
    - **Connection Id:** `postgres_dwh` _(to musi być identyczne co do litery z wartością `conn_id` w kodzie Twojego DAG-a)_
    - **Connection Type:** `Postgres` 
    - **Host:** `postgres` _(używamy nazwy kontenera z docker-compose)_ 
    - **Database:** `DataWarehouse`  
    - **Login:** `dwh_user1` _(zgodnie z naszym `.env`)_  
    - **Password:** `user1_password`  
    - **Port:** `5432` 
4. Zapisz (przycisk **Save**).