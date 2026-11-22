---
name: docker-audit
description: Run the read-only Docker hardening audit on a container, explain each finding with evidence, and recommend a specific Dockerfile fix. Use when asked to audit or harden a running container.
argument-hint: <container-name>
allowed-tools: Read, Bash(bash docker-audit.sh:*), Bash(docker ps:*), Bash(docker inspect:*), Bash(docker image inspect:*)
---

# docker-audit

Audit one running container. This skill gathers evidence and recommends. It never changes anything.

## Steps

1. If no container name is given in the arguments, run `docker ps --format '{{.Names}}'` and ask which one.
2. Run `bash docker-audit.sh <container-name>`.
3. Read the newest file in `reports/` for that container.
4. For every WARN and FAIL, quote the evidence line from the report and explain the risk in one sentence.
5. Recommend one specific Dockerfile fix as a diff, with the exact lines to add or change.
6. End with the command the owner runs to rebuild and recreate the container, and say that the owner runs it.

## Safety rules

- NEVER run `docker build`, `docker rm`, `docker stop`, `docker rmi`, `docker kill`, `docker run` or `docker compose`.
- NEVER edit a Dockerfile, a compose file or any other file. The owner applies the fix.
- Only the tools listed in `allowed-tools` are used.
- Do not print environment variable values from the container.
- Report failures honestly. Do not soften a FAIL into a WARN.
