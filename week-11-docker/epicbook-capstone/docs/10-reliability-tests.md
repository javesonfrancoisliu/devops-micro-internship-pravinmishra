# 10 Reliability tests

Run on the VM with the stack healthy. HTTP codes were read with `curl` against `http://127.0.0.1`.

## Test 1: backend stopped

`docker compose stop backend`

| Request | Result |
|---|---|
| `/` | `502` (page needs the backend) |
| `/assets/css/style.css` | `200` (frontend container still serves static files) |
| `/healthz` | `200` (proxy is alive) |

`docker compose start backend`, then `/` returns `200` again with no proxy restart. The proxy resolves the backend at request time, so it recovers on its own.

Finding: the app renders pages in the backend, so a backend outage takes the HTML pages down. The user sees the nginx `502 Bad Gateway` page. Improvement: a friendly `error_page 502` page served by the proxy.

## Test 2: database stopped

`docker compose stop db`

| Request | Result |
|---|---|
| `/health` | `503 {"status":"database unavailable"}` |
| backend container | stays `Up`, no crash loop |

`docker compose start db`, wait for healthy, then `/health` returns `200 {"status":"ok"}`.

Finding: the backend degrades and reports it, then reconnects by itself. Sequelize retries on the next request.

## Test 3: network isolation

From inside the proxy and frontend containers: `wget db:3306` returns `bad address 'db:3306'`. Only the backend is on the `back-tier` network. The `internal: true` flag also blocks outbound access from the database network.

## Test 4: data loss and restore

Cart rows deleted, then restored from `mysqldump`: carts 4, then 0, then 4. See `docs/05-persistence-and-backup.md`.

## Test 5: memory exhaustion (unplanned)

Running a `node:18` image build on the 1 GB VM at the same time as the stack pushed load above 12, left about 24 MB free, and the site returned `502`. After the build was killed, `docker ps` showed the proxy and frontend up for 35 minutes but the backend for 3 and the db for 5, so those two had been restarted by `restart: unless-stopped` and were `healthy` again.

Finding: `restart: unless-stopped` plus healthchecks recovered the stack. Builds do not belong on a 1 GB host (see `docs/08-ci-cd-pipeline.md`).

## Summary

| Failure | Detected by | Recovery |
|---|---|---|
| backend down | proxy `502` | automatic when the container returns |
| database down | `/health` `503` | automatic after db is healthy |
| data lost | manual | `restore.sh` |
| memory exhaustion | `502`, load average | kill the build, containers restart |
