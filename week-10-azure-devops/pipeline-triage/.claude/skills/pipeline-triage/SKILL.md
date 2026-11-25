---
name: pipeline-triage
description: Triage the latest Azure DevOps or GitHub Actions run of the EpicBook pipelines, name the failure category (dependency, build, test, authentication, agent), quote the log evidence and recommend one specific fix. Use when a pipeline run failed or when asked whether the pipelines are healthy.
argument-hint: [infra-epicbook|theepicbook]
allowed-tools: Read, Grep, Glob, Bash(./pipeline-triage.sh:*), Bash(bash pipeline-triage.sh:*)
---

# pipeline-triage

Diagnose the latest pipeline run. This skill gathers evidence and recommends. It never changes anything.

## Steps

1. Run `./pipeline-triage.sh` with the pipeline name from the arguments, or with no argument for every pipeline.
2. Read the newest file in `reports/` for each pipeline.
3. If RESULT is HEALTHY, say so, quote the Run id, Status and Result lines, and stop.
4. If RESULT is PENDING, say the run has not finished and stop.
5. If RESULT is FAILURE, state the CATEGORY, quote every EVIDENCE line exactly as written with its line number, and explain in one sentence why that line proves the category.
6. Give one specific recommended fix with the exact file and the exact change.
7. End with: the owner applies the fix, pushes, and then runs `/pipeline-triage` again to verify. Say that the owner does this, not Claude Code.

## Safety rules

- NEVER re-trigger, retry, cancel or approve a run.
- NEVER edit, create or delete any file. This skill has no Write or Edit tool.
- NEVER run `az` or `gh` directly. Use only `./pipeline-triage.sh`.
- NEVER read or print a PAT, token, service connection credential, SSH key or secret variable.
- Only the tools listed in `allowed-tools` are used.
- Report the result honestly. Do not turn a FAILURE into a warning, and do not guess a cause the evidence does not show.
