# 07 Cloud deployment notes (AWS)

## VM

| Item | Value |
|---|---|
| Provider | AWS EC2, region ap-southeast-5 (Malaysia) |
| Instance | t3.micro, Ubuntu 24.04, 12 GB gp3 encrypted |
| Provisioning | Terraform (`static-site/terraform`, the Assignment 1 stack) |
| Docker | docker.io 29.1.3, Compose plugin 2.40.3 (`docker-compose-v2`) |
| Public IP | `43.216.21.28` |
| Instance metadata | IMDSv2 required |

## Firewall (security group `docker-static-site`)

| Port | Source | Purpose |
|---|---|---|
| 22 | my public IP `/32` only | SSH |
| 80 | 0.0.0.0/0 | HTTP to the proxy |
| 443 | not open | no TLS in this lab, see below |

Ports 3306 and 8080 are never published, so they are not reachable from the internet. The database sits on an `internal` Docker network.

## Deploy steps

```
rsync -a epicbook-capstone/ ubuntu@43.216.21.28:~/epicbook-capstone/
ssh ubuntu@43.216.21.28
cd ~/epicbook-capstone
./scripts/setup.sh
sed -i 's#^ALLOWED_ORIGINS=.*#ALLOWED_ORIGINS=http://43.216.21.28#' .env
docker compose up -d --build
docker compose ps
```

`setup.sh` clones the app, applies the patch, copies the static assets and seed SQL, and generates `.env` with random passwords (the git-ignored `.env` is created on the VM and never leaves it).

## Result

- `http://43.216.21.28/` returns the EpicBook home page (`screenshots/a6-ss3.png`).
- `/cart` shows data fetched through the backend from MySQL (`screenshots/a6-ss4.png`).
- `/api/cart` returns `200` JSON, `/health` returns `{"status":"ok"}`.

## Production gaps

- No TLS. Production needs an ALB or Caddy with a certificate on 443, and an HTTP to HTTPS redirect.
- t3.micro has 1 GB RAM. Running a `node:18` build next to the stack exhausted memory and the site returned 502 until the build was killed, so builds belong in CI.
- Teardown: `terraform destroy` in the Assignment 1 stack after grading.
