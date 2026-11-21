# epicbook-risk-review

## Project Overview
- Ansible change risk review for the EpicBook deployment (DMI Week 9, Assignment 06). Owner: Javeson Francois Liu.
- `ansible/` holds the EpicBook playbook (`site.yml`), inventory and roles `common`, `nginx`, `epicbook`.
- `ansible-check-review.sh` runs a dry run and classifies changed tasks into four risk categories.

## Commands
- Reach the VM: `cd ansible && ansible web -i inventory.ini -m ping`
- Syntax check: `cd ansible && ansible-playbook -i inventory.ini site.yml --syntax-check`
- Risk review: `./ansible-check-review.sh`

## Safety Rules
- Claude Code is analysis only. Never apply changes.
- Never run `ansible-playbook` without `--check`. The real run is done by the human, manually.
- Never create, edit or delete files unless the human asks for that exact change.
- Never run `terraform apply`, `terraform destroy`, `rm`, or any command that changes the server or the cloud.
- Never read or print `.vault_pass`, `group_vars/all/vault.yml`, SSH keys or any password.
- Every report and summary must show the full name Javeson Francois Liu.

## Risk Categories
1. Destructive: remove, delete, purge, drop, absent.
2. Service disruption: restart, stop, reload, reboot.
3. Security and access: users, groups, SSH, sudo, firewall, permissions, passwords, keys.
4. Package and config drift: install, upgrade, template, copy, lineinfile.

## Decision
- The human decides whether to apply, after reading the report.
