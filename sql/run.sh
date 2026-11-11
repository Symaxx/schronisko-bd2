#!/bin/bash

set -euo pipefail

: "${MSSQL_SA_PASSWORD:?Brak MSSQL_SA_PASSWORD (sprawdz plik .env)}"
: "${APP_DB_PASSWORD:?Brak APP_DB_PASSWORD (sprawdz plik .env)}"

SQL_DIR="$(cd "$(dirname "$0")" && pwd)"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

if [ ! -x "$SQLCMD" ]; then
    SQLCMD="/opt/mssql-tools/bin/sqlcmd"
fi

run() {
    echo ">>> $1"
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -I \
        -v APP_PASSWORD="$APP_DB_PASSWORD" \
        -i "$SQL_DIR/$1"
}

case "${1:-setup}" in
    setup) run init.sql; run security.sql; run data.sql ;;
    test)  run test.sql ;;
    reset) run reset.sql ;;
    query) shift; "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -I -d schronisko -Q "$*" ;;
    all)   run reset.sql; run init.sql; run security.sql; run data.sql; run test.sql ;;
    *)     echo "Nieznana komenda: $1 (setup | test | reset | all | query)"; exit 1 ;;
esac
