# Assignment 2 — Deploy AStatic Website to AWS EC2 Using an Azure DevOps CI/CD Pipeline

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will import and personalize the Static Website, provision and configure an AWS EC2 instance using Terraform and Ansible, and create an Azure DevOps CI/CD pipeline that automatically deploys the website to Nginx through an SSH Service Connection.

---

# Task 0 — Verify the Existing Tooling and Self-Hosted Agent

## Goal

Confirm that Terraform, Ansible, AWS CLI, SSH, and the self-hosted Azure Pipelines agent are ready.

No submission screenshot is required for this task.

### What I checked

- `terraform version` and `ansible --version` run on my Mac controller.
- `aws sts get-caller-identity --profile javesonpersonal` answers, so the AWS CLI can reach the account.
- SSH key `~/.ssh/id_rsa_dmi_azdo` exists and its public half is the key pair Terraform installs on the target.
- The self-hosted agent `dmi-agent-01` is Online in the pool `self-hosted-linux` (built in Assignment 01).

---

# Task 1 — Import and Personalize the Azure Static Website Repository

## Goal

Import the Azure Static Website into Azure Repos and add your Full Name to the website.

## Evidence

### Screenshot 1 — Azure Static Website in Azure Repos

Add a screenshot of Azure Repos showing:

* Imported Azure Static Website repository
* Project files
* `index.html`

![Screenshot 1: Azure Static Website in Azure Repos](screenshots/a2-ss1-repo-files.png)

---

# Task 2 — Provision and Configure the Target EC2 Instance

## Goal

Provision the AWS EC2 instance using Terraform and configure Nginx, SSH access, and deployment permissions using Ansible.

No additional submission screenshot is required for this task.

### What I built

- Terraform (`terraform/`) creates one `t3.micro` Ubuntu 24.04 EC2 instance in `ap-southeast-5`, an encrypted 8 GB gp3 disk, a key pair and a security group.
- The security group allows TCP 22 only from my controller IP and from the agent public IP, and TCP 80 from the internet.
- Ansible (`ansible/site.yml`) installs and starts Nginx, gives the SSH user `ubuntu` ownership of `/var/www/html`, proves it by writing and removing a probe file as that user, and checks that Nginx answers HTTP 200.
- The pipeline copies files as `ubuntu`, so the write permission on `/var/www/html` is what makes the copy step work without root.

---

# Task 3 — Create the SSH Service Connection

## Goal

Create an Azure DevOps SSH Service Connection that can connect to the target EC2 instance using your selected SSH authentication method.

## Evidence

### Screenshot 2 — SSH Service Connection

Add a screenshot of the saved SSH Service Connection **Overview** page showing:

* Service Connection name
* SSH connection type

![Screenshot 2: SSH service connection Overview](screenshots/a2-ss2-ssh-connection.png)

> Do not expose a password, SSH private key, passphrase, or another credential.

Connection settings used: name `ubuntu-nginx-ssh`, host the EC2 public IP, port 22, user `ubuntu`, private key authentication, no passphrase.

---

# Task 4 — Create the Azure DevOps YAML Pipeline

## Goal

Create an Azure DevOps YAML pipeline that deploys the Azure Static Website to the target EC2 instance after a commit is pushed.

## Evidence

### Screenshot 3 — Azure Pipelines YAML

Add a screenshot of `azure-pipelines.yml` open in the Azure Repos editor showing:

* Push trigger
* Selected self-hosted agent pool
* Pipeline variables
* Repository checkout step
* Pipeline information step
* `CopyFilesOverSSH@0` task
* `SSH@0` verification task

![Screenshot 3: azure-pipelines.yml in Azure Repos](screenshots/a2-ss3-pipeline-yaml.png)

> Ensure that no password, SSH private key, PAT, or AWS credential is visible.

---

# Task 5 — Create, Authorize, and Run the Pipeline

## Goal

Run the Azure DevOps pipeline and confirm that the website files are transferred and verified successfully.

## Evidence

### Screenshot 4 — Successful Pipeline Run

Add a screenshot of the successful pipeline run and log summary showing:

* Overall pipeline status as **Succeeded**
* Pipeline information step completed
* File-copy step completed
* Remote-verification step completed
* Your Full Name visible in the pipeline output

![Screenshot 4: Successful pipeline run and Pipeline information log](screenshots/a2-ss4-pipeline-run.png)

---

# Task 6 — Verify the Website and Automatic Trigger

## Goal

Confirm that the website is accessible through the EC2 public IP address and that a new pushed commit automatically triggers another deployment.

## Evidence

### Screenshot 5 — Deployed Azure Static Website

Add a browser screenshot showing:

* Deployed Azure Static Website
* EC2 public IP address in the browser address bar
* Your Full Name
* Updated website content after the automatic deployment

![Screenshot 5: Deployed website with the updated footer](screenshots/a2-ss5-website.png)

## Final Website URL

`http://<target-vm-public-ip>`

Replace the placeholder with your actual website URL:

http://56.68.115.162

---

# Assignment Summary

Write a short summary of the completed CI/CD workflow.

I imported the Azure Static Website into Azure Repos and put my full name, Javeson Francois Liu, in the page footer. Terraform created the target EC2 instance with SSH and HTTP rules, and Ansible turned it into a ready Nginx web server where the `ubuntu` user can write to `/var/www/html`. An SSH service connection stores the connection details and the private key inside Azure DevOps, so the YAML never holds a credential. The pipeline triggers on a push to any branch, runs on my self-hosted agent, prints build information, copies the site with `CopyFilesOverSSH@0`, then verifies the live page with `SSH@0`: Nginx is active, the page returns HTTP 200 and it contains my full name. A new commit starts the same run again, so every push updates the website without a manual step.

---

# LinkedIn Requirement

## LinkedIn Post Screenshot

Add a screenshot of your LinkedIn post containing:

* What you automated
* How Terraform, Ansible, and Azure DevOps worked together
* Three to five lines describing the CI/CD workflow
* A screenshot of the successful pipeline or deployed website

Add your screenshot here.

## LinkedIn Post URL

[Paste your public LinkedIn post URL here]

> Do not expose AWS credentials, SSH private keys, passwords, PATs, or other sensitive information.

---

# Submission Instructions

* Include the short assignment summary.
* Include Screenshots 1–5.
* Include the final website URL.
* Include the LinkedIn post screenshot and URL.
* Confirm that the EC2 instance is running during grading.
* Do not expose a password, SSH private key, passphrase, PAT, AWS credential, account ID, or another secret.

---

# Completion Checklist

- [x] The correct Azure Static Website repository was imported into Azure Repos
- [x] `index.html` is visible in Azure Repos
- [x] Your Full Name was added to the website
- [x] The target EC2 instance was provisioned using Terraform
- [x] A suitable Ubuntu image and EC2 size were selected
- [x] Nginx was configured using Ansible
- [x] SSH login works using the selected authentication method
- [x] The SSH user can write to `/var/www/html`
- [x] TCP ports 22 and 80 are configured correctly
- [x] The self-hosted Azure Pipelines agent is online
- [x] The SSH Service Connection was created successfully
- [x] The YAML trigger includes all branches
- [x] The YAML uses the correct self-hosted agent pool
- [x] The copy and remote-verification tasks completed successfully
- [x] The pipeline status is **Succeeded**
- [x] A new pushed commit triggered the pipeline automatically
- [x] The Azure Static Website loads through the EC2 public IP address
- [x] Your Full Name is visible on the deployed website
- [x] Screenshots 1–5 are included and readable
- [x] The final website URL is included
- [ ] The LinkedIn post screenshot and URL are included
- [x] No sensitive information is exposed

---

*This submission is part of the DevOps Micro Internship (DMI) — Agentic AI Track.*
