# Bazodanowy system obsługi schroniska dla zwierząt

Projekt z przedmiotu **Bazy danych 2**.
Autorzy: Milan Pandey (284550), Mateusz Mamzer (284617).

## O projekcie

System do obsługi schroniska dla zwierząt. Przechowuje dane o zwierzętach (imię, gatunek, rasa,
data przyjęcia, stan zdrowia), a w kolejnych etapach także o adopcjach i pracownikach.
Pracownicy będą korzystać z niego na stacjonarnych terminalach w różnych częściach schroniska,
każdy na własnym koncie i z uprawnieniami zależnymi od roli.

To repozytorium zawiera obecnie etap 6: działający serwer bazy danych, przykładową tabelę,
widoki i testy. Aplikacja okienkowa w C# (.NET) dojdzie w kolejnych etapach.

## Jak działa system

System ma prostą budowę dwuwarstwową (klient-serwer) w sieci lokalnej:

- **Serwer** to baza Microsoft SQL Server 2022 Express uruchomiona w kontenerze Docker na jednym
  komputerze. Przechowuje dane, pilnuje ich spójności (klucze, ograniczenia, transakcje)
  i obsługuje zapytania.
- **Klienci** to aplikacja okienkowa na terminalach, która łączy się z serwerem bezpośrednio
  przez ADO.NET.

Domyślnie serwer jest dostępny tylko z komputera, na którym działa. Żeby terminale mogły łączyć się
przez sieć lokalną, ustawia się w pliku `.env` adres nasłuchu serwera i otwiera port 1433
w zaporze Windows. Klienci łączą się wtedy pod adresem IP tego komputera.

## Co jest w bazie

Tabela zwierząt z ograniczeniami (np. gatunek tylko z dozwolonej listy, imię nie może być puste),
indeks przyspieszający wyszukiwanie po gatunku oraz dwa widoki: lista psów i statystyki
według gatunków. Dane przykładowe ładują się tylko do pustej tabeli.

## Bezpieczeństwo

W bazie działają dwa rodzaje kont. Administrator zarządza strukturą bazy. Konto aplikacji ma
ograniczoną rolę: może odczytywać, dodawać, zmieniać i usuwać dane, ale nie może zmieniać
struktury (np. usunąć tabeli). Hasła są w pliku `.env`, który nie trafia do repozytorium.

## Jak uruchomić

Potrzebny jest Docker Desktop. Plik `.env.example` kopiuje się jako `.env` i ustawia w nim hasła
(min. 8 znaków, w tym małe i duże litery oraz cyfry, bez apostrofu). Serwer startuje poleceniem
`docker compose up -d`. Gdy kontener będzie gotowy (status `healthy`), skrypt
`sql/run.sh` uruchomiony w kontenerze tworzy bazę, konto aplikacji i dane przykładowe.

Ten sam skrypt z argumentem `test` uruchamia testy, a z argumentem `reset` albo `all` usuwa
i odtwarza bazę od zera. Wszystkie skrypty można uruchamiać wielokrotnie.

## Zawartość repozytorium

- `docker-compose.yml`: konfiguracja serwera bazy danych
- `.env.example`: wzór ustawień (hasła, adres nasłuchu serwera)
- `sql/init.sql`: baza, tabela, indeks, widoki
- `sql/security.sql`: konto aplikacji i jego uprawnienia
- `sql/data.sql`: dane przykładowe
- `sql/test.sql`: testy operacji na danych, ograniczeń, transakcji i uprawnień
- `sql/reset.sql`: usunięcie bazy i konta aplikacji
- `sql/run.sh`: skrypt uruchamiający powyższe w kontenerze