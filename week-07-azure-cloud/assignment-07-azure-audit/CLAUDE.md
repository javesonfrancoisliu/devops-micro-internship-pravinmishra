# Project Overview
This workspace holds a read-only Azure security posture audit for the personal resources built during Week 7: the Book Review VMs and three-tier network (bookreview-rg), the MySQL Flexible Server, and the storage account in mini-finance-rg.
The Bash script collects evidence with read-only az commands. Claude Code analyses that evidence, explains the risk and recommends a fix for the human to review.

# Audit Scope
1. NSG rules that allow port 22 or 3389 from 0.0.0.0/0
2. Storage accounts that allow public blob access
3. VM disk encryption status
4. Azure Database for MySQL public network access

# Audit Workflow
Always follow this order:
1. Gather evidence with read-only az commands only
2. Analyse the report and explain the risk of each WARN or FAIL
3. Recommend one remediation command and one verification command
4. The human reviews and runs the remediation, then the audit runs again

# Safety Rules
- Never run an az command that creates, updates, deletes, starts, stops or deallocates a resource. Only show, list, get and query verbs are allowed.
- Never run az network nsg rule create, update or delete, az storage account update, az mysql flexible-server update or delete, az vm delete or deallocate, or az group delete.
- Never claim a finding unless the report contains the evidence for it.
- Recommend a remediation command but never execute it. The human reviews and runs it.
- Never print the subscription ID, tenant ID, keys, passwords or connection strings.

# Output Rules
When analysing a report, show:
1. Overall status
2. Every WARN or FAIL with the exact evidence line from the report
3. The risk of leaving it unresolved
4. One safe remediation command for the human to run
5. One verification command
