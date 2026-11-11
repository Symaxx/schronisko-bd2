# Bazodanowy system obsługi schroniska dla zwierząt

Projekt z przedmiotu **Bazy danych 2**.
Autorzy: Milan Pandey (284550), Mateusz Mamzer (284617).

Baza danych **Microsoft SQL Server 2022 (Express)** uruchamiana w Dockerze. Obecny etap (6) to
przykładowa tabela, operacje CRUD, widoki, rola z ograniczonymi uprawnieniami i testy.
Docelowo dojdzie aplikacja okienkowa w C# (.NET) z ADO.NET.

## Wymagania

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (na Windows z WSL2)
- opcjonalnie: [VS Code](https://code.visualstudio.com/) z rozszerzeniem **SQL Server (mssql)**

## Uruchomienie

**1. Hasła.** Skopiuj wzór (`cp .env.example .env`, w cmd `copy .env.example .env`) i ustaw
`MSSQL_SA_PASSWORD` (administrator `sa`) oraz `APP_DB_PASSWORD` (login aplikacji).
Hasło: min. 8 znaków, 3 z 4 kategorii (małe, duże litery, cyfry, symbole), bez apostrofu (`'`).
Plik `.env` jest w `.gitignore`.

**2. Serwer.**

```bash
docker compose up -d
docker ps
```

Poczekaj na status `(healthy)` (ok. 30 s).

**3. Baza i dane.**

```bash
docker exec mssql_schronisko bash /sql/run.sh
```

**4. Testy.**

```bash
docker exec mssql_schronisko bash /sql/run.sh test
```

Na końcu powinien pojawić się komunikat `WSZYSTKIE TESTY ZAKONCZONE POMYSLNIE`.

## Pozostałe komendy

| Komenda | Działanie |
|---|---|
| `docker exec mssql_schronisko bash /sql/run.sh reset` | usuwa bazę i login aplikacji |
| `docker exec mssql_schronisko bash /sql/run.sh all` | reset + setup + testy |
| `docker exec mssql_schronisko bash /sql/run.sh query "SELECT * FROM dbo.Zwierze"` | pojedyncze zapytanie jako `sa` |
| `docker compose down` | zatrzymuje kontener (dane zostają) |
| `docker compose down -v` | zatrzymuje kontener i **kasuje dane** |

## Połączenie z bazą

Serwer: `localhost,1433` (tylko lokalnie), zaznacz *Trust server certificate*.
Administrator: login `sa`. Aplikacja: login `app_schronisko`. Hasła z `.env`.

```
Server=localhost,1433;Database=schronisko;User Id=app_schronisko;Password=<APP_DB_PASSWORD>;TrustServerCertificate=True;
```

## Skrypty `sql/`

```
init.sql      baza, tabela Zwierze, indeks, widoki
security.sql  login, użytkownik i rola aplikacji
data.sql      dane przykładowe
test.sql      testy CRUD, widoków, ograniczeń, transakcji i uprawnień
reset.sql     usunięcie bazy i loginu
run.sh        uruchamia skrypty w kontenerze (zapisuj z końcami linii LF)
```

Skrypty są idempotentne, można je uruchamiać wielokrotnie.

## Bezpieczeństwo

Aplikacja łączy się jako `app_schronisko` z rolą `rola_aplikacji`, która ma tylko
`SELECT/INSERT/UPDATE/DELETE` na tabeli i `SELECT` na widokach (bez `DROP` i `ALTER`).