# epicbook-prod

Terraform builds one AWS Ubuntu VM and one private RDS MySQL database. Three Ansible roles (`common`, `nginx`, `epicbook`) deploy the EpicBook Node.js app behind Nginx. Built by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 9, Assignment 05.

## Architecture

| Layer | Tool | What it does |
|---|---|---|
| Infrastructure | Terraform | EC2 Ubuntu 24.04, RDS MySQL 8.4 (private), key pair, web and database security groups |
| Configuration | Ansible roles | `common` installs base packages, Node.js, MySQL client and PM2; `nginx` proxies port 80 to the app; `epicbook` deploys, connects the database and runs the app under PM2 |

## Security rules

| Rule | Port | Source | Why |
|---|---|---|---|
| SSH | 22 | Controller IP only | Only the controller administers the VM |
| HTTP | 80 | Internet | Visitors reach EpicBook through Nginx |
| MySQL | 3306 | Web security group only | The database is never public |

The database password lives in an Ansible Vault file (`ansible/group_vars/all/vault.yml`) and in an ignored `secrets.auto.tfvars`. The vault password file `.vault_pass` is ignored by Git.

## Files

| Path | Purpose |
|---|---|
| `terraform/aws/` | Provider, variables, resources and outputs (no secret outputs) |
| `ansible/site.yml` | Runs roles `common`, `nginx`, `epicbook` in order |
| `ansible/group_vars/web.yml` | App, PM2 and database variables |
| `ansible/group_vars/all/vault.yml` | Encrypted database password |
| `ansible/roles/*` | The three roles |

## How to run

1. Create `terraform/aws/terraform.tfvars` with `controller_ip` and `terraform/aws/secrets.auto.tfvars` with `db_password`.
2. Provision: `cd terraform/aws && terraform init && terraform apply`.
3. Put `public_ip` into `ansible/inventory.ini` and `db_endpoint` into `ansible/group_vars/web.yml`.
4. Store the same password in the vault: `ansible-vault create ansible/group_vars/all/vault.yml` with `vault_db_password`.
5. Deploy: `cd ansible && ansible-playbook -i inventory.ini site.yml`.
6. Open `http://<public-ip>`.
7. Clean up: `terraform destroy`.
