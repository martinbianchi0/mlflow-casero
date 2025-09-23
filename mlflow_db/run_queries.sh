#!/usr/bin/env bash
set -euo pipefail

# === Cargar credenciales ===
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Falta .env"; exit 1
fi

# Configuración de psql
PSQL='psql "postgresql://'"$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE"'" \
  -X -q -v ON_ERROR_STOP=1 -P pager=off -P border=2 -P footer=off'

echo "==> Ejecutando consultas en ./consultas"

for file in $(ls -1 consultas/*.sql); do
  base="$(basename "$file" .sql)"

  echo ""
  echo "------------------------------------------------------------"
  echo "Consulta: $base"
  echo "Archivo : $file"
  echo "------------------------------------------------------------"

  # Ejecuta la consulta
  eval "$PSQL -f \"$file\""
done

echo ""
echo "Listo ✅"