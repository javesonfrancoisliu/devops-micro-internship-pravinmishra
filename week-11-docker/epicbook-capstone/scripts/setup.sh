#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

[ -d backend/app ] || git clone --depth 1 https://github.com/pravinmishraaws/theepicbook.git backend/app
git -C backend/app apply --check ../../patches/0001-health-cors-json-logs.patch 2>/dev/null \
  && git -C backend/app apply ../../patches/0001-health-cors-json-logs.patch

mkdir -p frontend/site logs/proxy backups
cp -R backend/app/public/. frontend/site/

cp backend/app/db/BuyTheBook_Schema.sql db-init/01-schema.sql
cp backend/app/db/author_seed.sql db-init/02-authors.sql
cp backend/app/db/books_seed.sql db-init/03-books.sql

if [ ! -f .env ]; then
  {
    echo "HTTP_PORT=80"
    echo "MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)"
    echo "DB_PASSWORD=$(openssl rand -hex 16)"
    echo "ALLOWED_ORIGINS=http://localhost"
  } > .env
  chmod 600 .env
fi
