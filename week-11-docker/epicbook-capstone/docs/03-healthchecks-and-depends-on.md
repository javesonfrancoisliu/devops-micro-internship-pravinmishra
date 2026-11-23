# 03 Healthchecks and startup order

## Healthchecks

| Service | Check | Interval, timeout, retries | Start period |
|---|---|---|---|
| db | `mysqladmin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD"` | 10s, 5s, 10 | 30s |
| backend | `wget -qO- http://127.0.0.1:8080/health` | 10s, 3s, 5 | 15s |
| frontend | `wget -qO- http://127.0.0.1:8080/healthz` | 10s, 3s, 5 | none |
| proxy | `wget -qO- http://127.0.0.1/healthz` | 10s, 3s, 5 | none |

All checks use `127.0.0.1`. `localhost` resolved to IPv6 inside the alpine images and the checks failed, so the address is explicit.

## /health on the backend

Added by `patches/0001-health-cors-json-logs.patch`. It calls `db.sequelize.authenticate()`:

- database reachable: `200 {"status":"ok"}`
- database down: `503 {"status":"database unavailable"}`

So the backend reports unhealthy when its dependency is gone, instead of only when the Node process dies.

## depends_on with service_healthy

```
proxy    -> frontend (healthy), backend (healthy)
backend  -> db (healthy)
```

Start order is db, then backend and frontend, then proxy. The proxy never opens port 80 before both upstreams answer their checks, and the backend never starts connecting before MySQL accepts connections (it avoids the first-boot race while MySQL initializes the seed SQL).

## Verified

`docker compose ps` shows all four services `healthy` (see `docs/10-reliability-tests.md` for the fault injection runs).
