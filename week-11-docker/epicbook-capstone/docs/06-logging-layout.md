# 06 Logging layout

## Where logs go

| Source | Format | Destination |
|---|---|---|
| proxy access log | JSON (`log_format json`) | `/var/log/nginx/access.log`, bind-mounted to `./logs/proxy/access.log`, and stdout |
| proxy error log | nginx text | `./logs/proxy/error.log` |
| backend request log | JSON line per request `{"time","method","url","status"}` | stdout |
| backend Sequelize SQL | plain text | stdout |
| db | MySQL text | stdout |
| frontend | nginx text | stdout |

## Container log rotation

Every service uses the `json-file` driver with `max-size: 10m` and `max-file: 3`, so a service holds at most 30 MB of logs.

## Proxy JSON fields

`time`, `remote_addr`, `request`, `status`, `bytes`, `request_time`, `upstream`, `user_agent`. The `upstream` field shows which container answered (frontend `:80` or backend `:8080`).

## Reading logs

```
docker compose logs -f proxy backend
docker compose logs --no-log-prefix proxy | jq .
tail -f logs/proxy/access.log | jq .
```

## Sample

Proxy:

```
{"time":"2026-11-22T17:12:42+00:00","remote_addr":"172.18.0.1","request":"GET /api/cart HTTP/1.1","status":200,"bytes":486,"request_time":0.062,"upstream":"172.18.0.3:8080","user_agent":"curl/8.5.0"}
```

Backend:

```
{"time":"2026-11-22T17:12:42.688Z","method":"GET","url":"/api/cart","status":200}
```

Screenshot: `screenshots/a6-ss2.png`.

## Notes

- `logs/` is git-ignored.
- The proxy log directory is on the host, so logs survive a proxy container rebuild.
