# Book Review App on AWS: Project Context

## Architecture
Three-tier Book Review App (Next.js frontend, Node.js and Express backend, MySQL) on AWS in ap-southeast-5, built only with Terraform.

- VPC 10.0.0.0/16 across two Availability Zones with six subnets: two public (web tier), two private app, two private database.
- Public Application Load Balancer in the public subnets forwards to the Web Tier (Nginx plus Next.js on EC2).
- Nginx proxies /api to the Internal Application Load Balancer in the private app subnets, which forwards to the Application Tier (Express on port 3001).
- Amazon RDS for MySQL 8.4, Multi-AZ, plus one read replica, in the private database subnets.
- One NAT gateway gives the private app tier outbound access only.

## Security boundaries
- Only the public ALB accepts internet traffic (port 80). Web instances accept port 80 from the public ALB security group only.
- The internal ALB accepts port 80 from the web security group only. App instances accept port 3001 from the internal ALB security group only.
- MySQL accepts port 3306 from the app security group only. RDS is never publicly accessible.
- No SSH. Access for troubleshooting is through AWS Systems Manager.
- No secrets in code, state output, user data or tfvars. The database password is a generated random_password stored in Secrets Manager and read by the app role at service start. The JWT secret is a generated Secrets Manager secret.

## Terraform requirements
- Modules: network, security, alb, iam, secrets, web, app, database. The root module only wires module outputs to module inputs.
- Provider versions are pinned. Run terraform fmt and terraform validate before every plan.
- Every resource is tagged through provider default_tags. No hardcoded account IDs, ARNs or credentials.
- No comments in Terraform code. Intent is expressed through names and variables.

## Human approval rules
- Claude may run init, validate, fmt, plan, show, output and read-only AWS describe or list commands.
- Claude must never run terraform apply, terraform destroy, any command with -auto-approve, or any AWS CLI command that creates, changes or deletes resources.
- The human reviews the plan, then runs apply and destroy personally.
- Claude never prints or reads secret values.

## Drift and Policy Review

### Project Overview
Read-only drift and policy review of this Terraform project. `AI Assignment/tf-drift-check.sh` gathers plan evidence, the `/tf-drift-review` skill analyses it, and the human decides and acts.

### Review Workflow
1. Run `bash "AI Assignment/tf-drift-check.sh"`. It writes `reports/latest-report.txt` and, only when changes are pending, `reports/tfplan.json`.
2. Read the report and, when it exists, `reports/tfplan.json`.
3. Report the status, affected resources, action types and risk.
4. Recommend an action and stop. The human acts, then the check runs again to verify.

### Safety Rules
- Never run terraform apply, terraform destroy or any command with -auto-approve.
- Never edit .tf files, state files or reports during a review.
- Never call a change safe without plan or report evidence. Answer INSUFFICIENT EVIDENCE instead.
- Never print secret values or account IDs.

### Output Rules
- Start with Overall Status (HEALTHY, WARN, FAIL or ERROR), then affected resources, action types, risk and the recommended human action.
- Cite the report line or the plan address for every claim.
