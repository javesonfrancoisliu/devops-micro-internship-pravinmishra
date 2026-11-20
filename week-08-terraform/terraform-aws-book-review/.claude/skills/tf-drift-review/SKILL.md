---
name: tf-drift-review
description: Read-only Terraform drift and policy review. Runs the evidence script, reads the report and explains status, affected resources, action types and risk. Never applies or destroys.
disable-model-invocation: true
allowed-tools: Bash(bash "AI Assignment/tf-drift-check.sh"*), Read, Grep
---

# Terraform Drift Review

Follow the pattern: Gather Evidence, Analyze, Human Reviews and Acts, Verify.

## Steps

1. Run `bash "AI Assignment/tf-drift-check.sh"` from the project root. Do not pass other commands.
2. Read `reports/latest-report.txt`. When the report lists pending changes, also read `reports/tfplan.json`.
3. Answer in this order: Overall Status, affected resources, action types, risk, recommended human action.
4. Cite the report line or plan address behind every claim.
5. Stop after the recommendation. The human decides and acts, then runs this review again to verify.

## Status meaning

- HEALTHY: plan exit code 0, no pending changes.
- WARN: plan exit code 2, pending changes, no policy finding.
- FAIL: plan exit code 2 with a destructive action (delete or replace) or an ingress rule open to 0.0.0.0/0 on a port other than 80 and 443.
- ERROR: plan exit code 1, report the Terraform error and stop.

## Safety rules

- Never run terraform apply, terraform destroy or any command with -auto-approve.
- Never write or edit files. This skill has no Write tool on purpose.
- Never call a change safe without evidence from the report or the plan. Answer INSUFFICIENT EVIDENCE instead.
- Never print secret values or account IDs.
