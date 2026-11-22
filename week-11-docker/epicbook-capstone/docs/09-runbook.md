# 09 Operations runbook

All commands run in `~/epicbook-capstone` on the VM.

## Start

```
./scripts/setup.sh
docker compose up -d --build
docker compose ps
curl -s http://127.0.0.1/health
```

Order is enforced by healthchecks: db, then backend and frontend, then proxy. Expect all four `healthy` within about 60 seconds on first start (MySQL loads the seed SQL).

## Stop

| Goal | Command | Data |
|---|---|---|
| Stop, keep everything | `docker compose stop` | kept |
| Remove containers, keep data | `docker compose down` | volume kept |
| Wipe including database | `docker compose down -v` | volume deleted, never on a live stack |

## Restart one service

```
docker compose restart backend
docker compose up -d --force-recreate backend
```

The proxy re-resolves `backend` every 10 seconds, so no proxy restart is needed.

## Rotate secrets

| Secret | Steps |
|---|---|
| `DB_PASSWORD` | `./scripts/backup.sh`; change the MySQL user password with `ALTER USER`; edit `.env`; `docker compose up -d --force-recreate backend` |
| `MYSQL_ROOT_PASSWORD` | `ALTER USER 'root'@'%'` and `'root'@'localhost'`; edit `.env`; `docker compose up -d --force-recreate db` (healthcheck uses it) |
| SSH key | add new key to `authorized_keys`, test, remove the old one |

The `MYSQL_*` variables only seed the first start. Editing `.env` alone does not change the password inside an existing volume.

## Disaster recovery

| Scenario | Action |
|---|---|
| Data deleted or corrupted | `./scripts/restore.sh backups/<latest>.sql` |
| db container lost, volume intact | `docker compose up -d db` |
| Volume lost | `docker compose up -d db` (seed SQL runs), then restore the latest dump |
| VM lost | `terraform apply` the VM stack, deploy steps in `docs/07-cloud-deployment-notes.md`, restore the off-host dump |

RPO equals the backup interval. RTO for a restore on this stack was under 1 minute.

## Where to look

| Symptom | Check |
|---|---|
| 502 on `/` | `docker compose ps backend`, `docker compose logs backend` |
| 503 on `/health` | `docker compose ps db`, `docker compose logs db` |
| Slow or no response | `free -m` (VM has 1 GB RAM), `docker stats --no-stream` |
| Request history | `tail -f logs/proxy/access.log` |

## Cost

One t3.micro plus 12 GB gp3. Destroy the VM stack when finished.
