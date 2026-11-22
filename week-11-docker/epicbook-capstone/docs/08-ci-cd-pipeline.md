# 08 CI/CD pipeline (optional task, not built)

This task is optional and was not implemented in this submission. The design below is what I would build next.

## Planned GitHub Actions workflow

| Stage | Step |
|---|---|
| Trigger | push to `main` touching `week-11-docker/epicbook-capstone/**` |
| Build | `docker compose build` on the runner (builds run in CI, not on the 1 GB VM) |
| Tag | `epicbook-backend:<git sha>` and `epicbook-frontend:<git sha>` |
| Push | Docker Hub or ECR, one immutable tag per commit |
| Deploy | SSH to the VM (key in GitHub secrets), `docker compose pull && docker compose up -d` |
| Verify | `curl -f http://<ip>/health`, fail the job on non-200 |
| Rollback | redeploy the previous sha tag |

## Why it matters for this stack

- Building `node:18` on the t3.micro starved memory and took the site down (see `docs/07-cloud-deployment-notes.md`). CI removes builds from the VM.
- The compose file would reference registry images by sha instead of `build:`.
