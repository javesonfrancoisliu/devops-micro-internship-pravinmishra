# 08 CI/CD pipeline

Workflow file: `.github/workflows/epicbook-capstone-ci.yml` (repository root). Status: written and validated locally with `actionlint`; the real GitHub Actions run has not been executed yet.

## Triggers

| Trigger | Detail |
|---|---|
| `push` | branch `main`, paths `week-11-docker/epicbook-capstone/**` |
| `workflow_dispatch` | inputs `deploy` (boolean, default false) and `rollback_sha` (optional 40 character sha) |

Permissions are `contents: read`. Only `actions/*` and `docker/*` actions are used, at current major versions that run on Node 24.

## Job 1: build

| Step | What it does |
|---|---|
| Throwaway env | writes `.env` with random `openssl rand -hex 16` passwords created in the job, not secrets |
| Setup | `scripts/setup.sh` clones the upstream app, applies the patch, copies assets and seed SQL (these are git-ignored, so CI must generate them) |
| Build | `docker/build-push-action` builds `backend` and `frontend` with `push: false`, `load: true` |
| Tags | `epicbook-backend:<git sha>` and `epicbook-frontend:<git sha>` |
| Sizes | `docker image ls` output, also written to the job summary |
| Smoke test | a generated compose override pins the two sha-tagged images, `docker compose -p ci-smoke up -d --no-build --wait`, then `curl -f http://127.0.0.1:80/health` with up to 20 retries, 3 s apart |
| Teardown | `docker compose -p ci-smoke down -v`, runs even on failure; logs are dumped on failure |
| Export | only for a manual deploy: `docker save` of the two images uploaded as a one-day artifact |

## Job 2: deploy

Runs only for `workflow_dispatch` with `deploy` true, after the build job passes.

1. Gate step: reads `SSH_HOST`, `SSH_USER`, `SSH_KEY` into environment variables. If any is empty it prints a notice and every later step is skipped, so the job ends green (skipped cleanly), not failed.
2. Writes the key to a `600` file, runs `ssh-keyscan` for the host, and uses plain `ssh` with `StrictHostKeyChecking=yes` against that file.
3. Sends `docker-compose.yml` and `proxy/nginx.conf` to `~/epicbook-capstone` on the VM, then streams the built images with `docker load` (no registry is used, so the images deployed are exactly the ones that passed the smoke test).
4. On the VM: writes `.deploy-images.yml` pinning the sha tags, `docker compose pull --ignore-buildable` (nginx and mysql), `docker compose up -d --no-build --wait`, then `curl -f /health` with retries.
5. If the health check fails and a previous override exists, the VM is brought back to the previous tag and the job fails.
6. The key files are deleted at the end.

The VM keeps its own git-ignored `.env`, seed SQL and volumes; the pipeline never writes them.

## Rollback

Run the workflow manually with `deploy` true and `rollback_sha` set to an earlier commit sha. The artifact steps are skipped and the VM re-points the stack at `epicbook-backend:<sha>` and `epicbook-frontend:<sha>`, which must still exist on the VM from an earlier deploy (the job fails early if they do not).

## Run history

- Run 1 (push to main) failed at "Fetch app source and seed data": `db-init` is untracked, so `setup.sh` could not copy the seed files. Fix: `mkdir -p db-init` in `setup.sh`.
- Run 2 (push to main) passed the build job end to end. Run: https://github.com/javesonfrancoisliu/devops-micro-internship-pravinmishra/actions/runs/45660860885

## Current limits

- The VM from `docs/07-cloud-deployment-notes.md` was destroyed, so the deploy job is skipped because the three secrets are not set. The deploy steps were not run against a real host.
- `ssh-keyscan` trusts the host key on first contact. Pin the key in a secret for stricter verification.
- The workflow uses the upstream repository `pravinmishraaws/theepicbook` at its default branch through `setup.sh`, so an upstream change can break the build.
- No TLS, no registry push, and no image scanning.

## Why it matters for this stack

Building `node:18` on the t3.micro starved memory and took the site down (see `docs/07-cloud-deployment-notes.md`). CI builds on the runner and the VM only loads finished images.
