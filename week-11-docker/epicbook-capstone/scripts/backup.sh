#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p backups
out="backups/bookstore-$(date +%Y%m%d-%H%M%S).sql"
docker compose exec -T db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --databases bookstore 2>/dev/null' </dev/null > "$out"
echo "$out"
