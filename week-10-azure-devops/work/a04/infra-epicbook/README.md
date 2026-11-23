# infra-epicbook

Terraform for the EpicBook infrastructure on Azure. Built by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 10, Assignment 04.

## Responsibility

This repository only creates infrastructure. It does not install or configure software. The application and its Ansible roles live in the separate `theepicbook` repository.

| Resource | Purpose |
|---|---|
| Resource group, virtual network, three subnets | Network for frontend, backend and database |
| Network security groups | Frontend: SSH from the agent only, HTTP from the internet. Backend: SSH and port 8080 from the frontend subnet only |
| Frontend VM with public IP | Nginx reverse proxy |
| Backend VM | Node.js EpicBook application |
| MySQL flexible server, private DNS zone, database `bookstore` | Private database reachable only inside the virtual network |

## Outputs

| Output | Used by |
|---|---|
| `app_public_ip` | `theepicbook` pipeline variable `APP_PUBLIC_IP` |
| `mysql_fqdn` | `theepicbook` pipeline variable `MYSQL_FQDN` |
| `backend_private_ip` | Reference, matches the default in `theepicbook` |

## Pipeline

`azure-pipelines.yml` signs in with the Azure Resource Manager service connection `azure-spn-epicbook`, then runs `terraform init`, `fmt`, `validate`, `plan` and `apply`. State is stored in an Azure Storage container. Secrets come from the variable group `epicbook-secrets`.
