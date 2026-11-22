# Docker Container Hardening Audit

## Project overview

- Read-only audit of the running EpicBook containers (capstone stack in `../epicbook-capstone`).
- `docker-audit.sh` inspects one container and writes a report in `reports/`.
- The `/docker-audit` skill reads the report and recommends a Dockerfile fix.

## Hardening workflow

1. Confirm the stack is up: `docker ps`.
2. Run the audit: `bash docker-audit.sh <container-name>`.
3. Read `reports/audit-<container>-<timestamp>.txt`.
4. Explain each WARN and FAIL with the evidence line from the report.
5. Recommend one specific Dockerfile change as a diff in chat.
6. The owner edits the Dockerfile, rebuilds and recreates the container, then re-runs the audit.

## Safety rules

- NEVER run `docker build`, `docker rm`, `docker stop`, `docker rmi`, `docker kill`, `docker run` or `docker compose up`.
- NEVER edit a Dockerfile, a compose file or any file outside `reports/`.
- Allowed Docker commands: `docker ps`, `docker inspect`, `docker image inspect`.
- Never print secret values from container environment variables.
- Report findings honestly, including failures.
