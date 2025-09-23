#!/usr/bin/env bash
set -euo pipefail

# Cargar variables
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Falta .env"; exit 1
fi

# Mostrar variables de conexión (sin PGPASSWORD por seguridad)
echo "==> Variables de conexión:"
echo "  PGHOST=$PGHOST"
echo "  PGPORT=$PGPORT"
echo "  PGUSER=$PGUSER"
echo "  PGDATABASE=$PGDATABASE"
echo ""

# Conexión al sistema
PSQL_SYS="psql postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/postgres -v ON_ERROR_STOP=1"

# Verificar si existe la base definida en $PGDATABASE, si no, crearla
EXISTS=$($PSQL_SYS -At -c "SELECT 1 FROM pg_database WHERE datname='${PGDATABASE}';" || true)
if [ -z "$EXISTS" ]; then
  echo "==> Creando base ${PGDATABASE}..."
  $PSQL_SYS -c "CREATE DATABASE \"${PGDATABASE}\";"
else
  echo "==> Base ${PGDATABASE} ya existe."
fi

# Conexión a la base de trabajo
PSQL="psql postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE} -v ON_ERROR_STOP=1"

echo "==> Probando conexión..."
$PSQL -c "SELECT version();"

echo "==> Aplicando create_tables.sql..."
$PSQL -f create_tables.sql

echo "==> Cargando datos (BEGIN)..."
$PSQL <<'SQL'
BEGIN;
\i load.sql
COMMIT;
SQL

echo "==> Conteos por tabla:"
$PSQL -At -c "
SELECT relname AS tabla, n_live_tup AS approx_rows
FROM pg_stat_all_tables
WHERE schemaname='public'
ORDER BY relname;"

echo "Listo ✅"