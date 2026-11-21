# ansible-adhoc-lab

Three-VM lab for the DevOps Micro Internship (DMI), Week 9, Assignment 02, built by **Javeson Francois Liu**. Terraform provisions the servers on AWS, then Ansible ad-hoc commands manage them from the controller set up in Assignment 01.

## Architecture

| Role | Count | Purpose | Open ports |
|---|---|---|---|
| web | 1 | Web server (nginx) | 22 from the controller only, 80 from the internet |
| app | 1 | Application server | 22 from the controller only |
| db | 1 | Database server | 22 from the controller only |

- Cloud: AWS, region `ap-southeast-5`, default VPC.
- Image: Ubuntu 24.04 LTS, instance type `t3.micro`.
- Access: SSH key `~/.ssh/id_ed25519_ansible`, user `ubuntu`.

## Layout

| Path | Purpose |
|---|---|
| `terraform/providers.tf` | Terraform and AWS provider versions |
| `terraform/variables.tf` | Region, instance type, server roles, key path, controller IP |
| `terraform/main.tf` | Key pair, security groups, three instances built with `for_each` |
| `terraform/outputs.tf` | `public_ips` map from role to public IP |
| `ansible/inventory.ini` | Hosts grouped as `web`, `app` and `db` |

## Usage

1. Set your controller IP in `terraform/terraform.tfvars` (ignored by Git): `controller_ip = "<your public IP>"`.
2. Provision: `cd terraform && terraform init && terraform apply`.
3. Read the addresses: `terraform output public_ips`.
4. Put the addresses into `ansible/inventory.ini`.
5. Check the inventory: `cd ../ansible && ansible-inventory -i inventory.ini --graph`.
6. Run ad-hoc commands, for example `ansible -i inventory.ini all -m ping`.
7. Clean up when done: `cd ../terraform && terraform destroy`.

## Rules

- SSH is open to the controller IP only, never to `0.0.0.0/0`.
- HTTP is open on the web host only.
- Never commit state files, `.tfvars`, private keys or account IDs.
- Destroy the lab after the screenshots to stop AWS charges.
