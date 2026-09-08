import pandas as pd
from pathlib import Path


#######################################################################################################################
# Pobieramy bezwzględną ścieżkę do pliku skryptu i idziemy dwa foldery wyżej
# Path(__file__) -> analize_extracts.py
file_path = Path(__file__).resolve().parent.parent / "datasets" / "source_crm" / "cust_info.csv"

#Sprawdzanie czy plik w ogóle istnieje przed odczytem
if not file_path.exists():
    raise FileNotFoundError(f"Brak pliku w: {file_path}")

#######################################################################################################################
# Wczytujemy plik podając jego strukturę fizyczną
df = pd.read_csv(
    file_path,
    sep=',',              # Separator kolumn (często przecinek ',' lub średnik ';')
    encoding='utf-8'      # Kodowanie znaków (w Polsce pliki z Excela to często 'windows-1250' lub 'cp1250')
)

# Użycie context managera – parametry resetują się po wyjściu z bloku 'with'
with pd.option_context('display.max_columns', None, 'display.width', 1000):

# Analiza
    print (f"\n1. Losowy podgląd danych (daje lepszy obraz niż pierwsze 5 wierszy)")
    print(df.sample(5))

    print(f"\n# 1.1. Alternatywa (transpozycja): wyświetlenie 1 wiersza w pionie, co ułatwia czytanie wielu kolumn")
    print(df.sample(1).T)

    print (f"\n# 2. Podgląd pierwszych 5 wierszy (aby zrozumieć strukturę)")
    print(df.head())

    print (f"\n# 3. Podstawowe informacje: liczba wierszy, nazwy kolumn i typy danych")
    print(df.info())

    print (f"\n# 4. Sprawdzenie, ile jest brakujących (pustych) wartości w każdej kolumnie")
    print(df.isnull().sum())

    print (f"\n# 5. Szybkie statystyki matematyczne dla kolumn liczbowych (średnia, min, max)")
    print(df.describe())

    print (f"\n# 6. Sprawdzenie, jakie typy pandas zgadł domyślnie")
    print(df.dtypes)

    # 2. Usuwanie duplikatów całych wierszy
    #df = df.drop_duplicates()

    # 3. Zastępowanie braków danych (np. NULL) domyślną wartością
    #df["cst_gndr"] = df["cst_gndr"].fillna(0.0)

    # 4. Asertywna weryfikacja unikalności klucza przed wysłaniem do bazy
    assert df['cst_id'].is_unique, "Błąd: Znaleziono zduplikowane cst_id!"

