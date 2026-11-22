#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM bookstore.Cartbook; DELETE FROM bookstore.Cart;" 2>/dev/null' </dev/null
echo "cart data deleted"
