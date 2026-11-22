# 05 Persistence and backup

## Persistence

- MySQL data directory `/var/lib/mysql` lives on the named volume `db-data`.
- `docker compose down` keeps the volume. `docker compose down -v` deletes it and MUST NOT be used on a live stack.
- `./db-init` is mounted read-only into `/docker-entrypoint-initdb.d`. It runs only when the volume is empty (first start).

## Backup plan

| Item | Value |
|---|---|
| Method | logical dump, `mysqldump --single-transaction` inside the db container |
| Command | `./scripts/backup.sh` |
| Output | `backups/bookstore-<timestamp>.sql` (host local time) |
| Frequency (plan) | daily at 02:00 by cron on the host, and before every upgrade |
| Retention (plan) | 7 daily files, older ones removed by cron |
| Off-host copy | `aws s3 cp backups/ s3://<bucket>/epicbook/ --recursive` (not configured in this lab) |
| Restore | `./scripts/restore.sh backups/<file>.sql` |

Cron line for the host (planned, not installed in this lab; only the manual drill below was run):

```
0 2 * * * cd /home/ubuntu/epicbook-capstone && ./scripts/backup.sh
```

## Restore drill (live, on the VM)

Run with `scripts/db-counts.sh`, `backup.sh`, `simulate-loss.sh`, `restore.sh`.

| Step | State |
|---|---|
| 1 before backup | books=54 carts=4 |
| 2 backup | `bookstore-20261122-173526.sql`, 34309 bytes |
| 3 after simulated loss (Cartbook and Cart rows deleted) | books=54 carts=0 |
| 4 after restore | books=54 carts=4 |

Screenshot: `screenshots/a6-ss1.png`.

## Limits

- A logical dump captures one point in time. Writes after the dump are lost on restore (RPO up to 24 hours with the daily schedule).
- Backups on the same VM do not survive loss of the VM, so the off-host copy is required in production.
