#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -N -e "SELECT CONCAT(\"books=\",(SELECT COUNT(*) FROM bookstore.Book),\" carts=\",(SELECT COUNT(*) FROM bookstore.Cart))" 2>/dev/null' </dev/null
