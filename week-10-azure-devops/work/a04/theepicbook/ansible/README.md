# EpicBook Ansible

Ansible for the `theepicbook` repository. Built by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 10, Assignment 04.

## Responsibility

This folder only configures servers and deploys the application onto the infrastructure created by the `infra-epicbook` repository.

| Role | Hosts | Job |
|---|---|---|
| `common` | frontend, backend | Base packages |
| `backend` | backend | Node.js, application code, systemd service, MySQL seed data |
| `frontend` | frontend | Nginx reverse proxy to the backend private IP |

## Inputs from the Infra Pipeline

| File | Placeholder | Source |
|---|---|---|
| `inventory.ini.tpl` | `__APP_PUBLIC_IP__` | Output `app_public_ip` |
| `vars/mysql.yml.tpl` | `__MYSQL_FQDN__` | Output `mysql_fqdn` |

The pipeline renders both templates from the pipeline variables `APP_PUBLIC_IP` and `MYSQL_FQDN`. The database password and the SSH key never appear in Git: the password comes from the variable group `epicbook-secrets` and the key from Azure DevOps Secure Files.
