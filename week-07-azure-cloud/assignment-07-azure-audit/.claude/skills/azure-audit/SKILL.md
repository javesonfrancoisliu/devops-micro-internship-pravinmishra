---
name: azure-audit
description: Run the read-only Azure security posture audit script, explain every finding and its risk, and recommend (never run) a remediation command.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# Azure Audit Skill

When `/azure-audit` is invoked:
1. Read `CLAUDE.md` before doing anything else.
2. Run `bash scripts/azure-audit.sh || true`.
3. Read `reports/azure-audit-report.txt`.
4. Report:
- Overall status
- Every WARN or FAIL result with the exact evidence line from the report
- The risk of leaving each finding unresolved (for example: SSH open to 0.0.0.0/0 exposes the VM to internet-wide brute force; public blob access can leak files; an unencrypted disk is a compliance risk; public MySQL access exposes the database to the internet)
- One exact, safe `az` remediation command per finding for the human to review
- One verification command to confirm the fix
5. If every check passes, state that no remediation is required.
6. Do not edit files.
7. Never run an `az` command that creates, updates, deletes, starts, stops or deallocates a resource. Only show, list, get and query verbs are allowed.
8. Never execute the recommended remediation yourself. Ask the human to review and run it.
