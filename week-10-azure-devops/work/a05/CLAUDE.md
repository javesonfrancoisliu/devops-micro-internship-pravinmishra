# Pipeline Triage

## Project overview

- Read-only failure triage for the dual-pipeline EpicBook project (DMI Week 10, Assignment 05). Owner: Javeson Francois Liu.
- Azure DevOps organization `javeson-dmi`, project `dmi-week10`, pipelines `infra-epicbook` (Terraform) and `theepicbook` (Ansible).
- `pipeline-triage.sh` fetches the latest run of each pipeline and classifies a failure into one of five categories: dependency, build, test, authentication, agent.
- The `/pipeline-triage` skill runs the script, reads the report and explains the result with quoted evidence.

## Workflow

1. Gather: run `./pipeline-triage.sh`. It reads run status and failed-step logs only.
2. Analyze: read the newest file in `reports/`, name the category, quote the evidence lines, recommend one specific fix.
3. Human applies the fix: the owner edits, commits, pushes and re-runs. Claude Code never does this.
4. Verify: after the owner pushes, run `./pipeline-triage.sh` again and confirm the result is healthy.

## Commands

- Triage all pipelines: `./pipeline-triage.sh`
- Triage one pipeline: `./pipeline-triage.sh theepicbook`
- Classify a saved log: `./pipeline-triage.sh --log-file fixtures/dependency-npm-404.log`
- Self-test and read-only audit of the script: `./pipeline-triage.sh --self-test`

## Safety rules

- NEVER re-trigger, retry, cancel or approve a pipeline run, on Azure DevOps or GitHub Actions.
- NEVER modify pipeline YAML, Terraform, Ansible or any file outside `reports/`.
- NEVER read or print a secret, token, PAT, service connection credential, SSH key or secret variable value.
- Only the commands listed under Commands are allowed. `az` and `gh` are used by the script, never directly.
- Report failures honestly and quote the exact log line. Do not guess a cause that the log does not show.
- Every report and summary shows the full name Javeson Francois Liu.

## Decision

- The human decides whether and how to fix, after reading the report.
