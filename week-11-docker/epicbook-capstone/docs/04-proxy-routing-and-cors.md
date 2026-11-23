# 04 Reverse proxy routing and CORS

## Routing (`proxy/nginx.conf`, nginx 1.27-alpine)

| Path | Upstream | Why |
|---|---|---|
| `/healthz` | answered by the proxy (`200 ok`) | liveness without touching upstreams, not logged |
| `/assets/` | `frontend:8080` | static files, gzip_static, 7 day cache |
| `/api/` | `backend:8080` | JSON API |
| `/` | `backend:8080` | the app renders pages server-side, so the backend serves HTML |

Design notes:

- `resolver 127.0.0.11 valid=10s` with upstreams held in variables (`$backend_host`, `$frontend_host`). nginx resolves names at request time through Docker DNS, so a restarted container with a new IP is picked up without reloading the proxy. With a static `proxy_pass backend:8080` nginx would refuse to start when the backend is down, or cache a stale IP.
- `server_tokens off`, plus `X-Content-Type-Options`, `X-Frame-Options` and `Referrer-Policy` headers.
- `X-Real-IP`, `X-Forwarded-For` and `X-Forwarded-Proto` are passed to the backend.

## CORS allowlist

The backend (patched `server.js`) reads `ALLOWED_ORIGINS` (comma separated, default `http://localhost`) and applies a middleware on `/api`:

- request `Origin` in the list: response carries `Access-Control-Allow-Origin: <that origin>` and `Vary: Origin`
- `OPTIONS` preflight from an allowed origin: `204`
- origin not in the list: no `Access-Control-Allow-Origin` header, so the browser blocks the call

For the cloud run the value is `http://43.216.21.28`.

## Verified (local run)

- allowed origin: header present, preflight `204`
- disallowed origin: header absent
