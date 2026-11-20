# Terraform Drift Review Summary

**Reviewer:** Javeson Francois Liu

## 1. Change Introduced

I added a security group ingress rule for TCP 22 from 0.0.0.0/0 to the web tier security group (`module.security.aws_security_group.web`) in the Terraform code only. It was a Terraform configuration change, not true infrastructure drift. It was never applied, so AWS was never touched.

## 2. Evidence Collected

`terraform plan -detailed-exitcode` returned exit code 2 and `reports/tfplan.json` listed one pending change: `module.security.aws_security_group.web` with action `update`. The ingress list in the plan contained port 22 open to 0.0.0.0/0. The saved evidence is `reports/drift-detected-report.txt`.

## 3. Risk Assessment

The Bash check `check_open_ingress` reported the web security group allowing 22-22 from 0.0.0.0/0, so the status was FAIL. Claude Code explained that this opens SSH to the internet and breaks the project rule that access is through Systems Manager only. The action was an in-place update, not a delete or a replacement.

## 4. Human-Approved Action

I reviewed the plan evidence and chose to revert the test rule in the code instead of applying it. No `terraform apply` was needed, because the change had never reached AWS. Claude did not run any infrastructure-changing command.

## 5. Verification

After the revert, the check script returned plan exit code 0, "Pending changes: none" and Overall Status HEALTHY (`reports/resolved-report.txt`). A second `/tf-drift-review` run confirmed HEALTHY with no pending changes.

## 6. Safety Decision

Claude can gather and analyse evidence safely because those steps only read. Apply and destroy change real infrastructure and may be irreversible, so a human must read the plan and take responsibility. The skill has no Write tool, the script never calls apply, and a PreToolUse hook blocks `terraform apply` while the latest report is FAIL.

## 7. Agentic Loop Mapping

- Gather: `tf-drift-check.sh` ran the plan and wrote the report and the sanitised plan JSON.
- Analyze: `/tf-drift-review` read the report and explained status, resources, action type and risk.
- Human Act: I decided to revert the rule and edited the code myself.
- Verify: the script and the skill ran again and both showed HEALTHY.
