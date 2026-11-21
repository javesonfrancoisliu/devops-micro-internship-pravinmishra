# mini-finance

Terraform builds an Azure Ubuntu VM, and a multi-play Ansible playbook deploys the Mini Finance website on it. Built by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 9, Assignment 04.

## Architecture

| Layer | Tool | What it does |
|---|---|---|
| Infrastructure | Terraform | Resource group, virtual network, subnet, static public IP, network security group, network interface and the `mini-finance` Ubuntu 24.04 VM |
| Configuration | Ansible | Installs Nginx, Git and Rsync, clones the site, syncs it to `/var/www/html/` and verifies it |

## Security rules

| Rule | Port | Source | Why |
|---|---|---|---|
| `Allow-SSH` | 22 | My public IP only | Only the controller can administer the VM |
| `Allow-HTTP` | 80 | Internet | Visitors must reach the website |

## Files

| Path | Purpose |
|---|---|
| `terraform/providers.tf` | Terraform and AzureRM provider versions |
| `terraform/variables.tf` | Region, VM size, admin user, key path, controller IP |
| `terraform/main.tf` | All Azure resources |
| `terraform/outputs.tf` | `public_ip` output |
| `ansible/inventory.ini` | The VM in the `web` group |
| `ansible/site.yml` | Three plays: install, deploy, verify |

## How to run

1. Set `controller_ip` in `terraform/terraform.tfvars` (ignored by Git).
2. Provision: `cd terraform && terraform init && terraform apply`.
3. Read the address: `terraform output public_ip`.
4. Put the address into `ansible/inventory.ini`.
5. Check access: `ssh azureuser@<public-ip> hostname` returns `mini-finance`.
6. Check Ansible: `cd ../ansible && ansible web -i inventory.ini -m ping`.
7. Validate: `ansible-playbook -i inventory.ini site.yml --syntax-check`.
8. Deploy: `ansible-playbook -i inventory.ini site.yml`.
9. Open `http://<public-ip>` in a browser.
10. Clean up: `terraform destroy`.

## What I learned

- Terraform creates the machine and Ansible configures it, so each tool does the job it is best at.
- The public IP from `terraform output` feeds straight into the Ansible inventory.
- Restricting SSH to one IP and opening only port 80 keeps the exposed surface small.
- `rsync` copies only changed files, so a re-run is fast and safe.
- The `uri` module with `assert` turns "it looks fine" into a check that fails the run.
