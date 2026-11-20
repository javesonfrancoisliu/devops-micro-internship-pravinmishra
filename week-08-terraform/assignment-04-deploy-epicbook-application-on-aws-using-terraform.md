# Assignment 4 — Deploy EpicBook Web App on AWS Using Terraform Modules and Amazon RDS for MySQL

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will use reusable Terraform modules to provision the AWS infrastructure required by EpicBook. You will create a custom VPC, one public subnet, two private database subnets across different Availability Zones, an Internet Gateway, a public route table, Security Groups, an EC2 Linux instance, and a private Amazon RDS for MySQL database.

You will use EC2 `user_data` to install the required software, initialize the EpicBook database, connect the application to Amazon RDS, configure Nginx, validate the complete browser-to-database workflow, destroy the resources after testing, and publish the required LinkedIn post.

---

# Task 0 — Set Up and Verify the Terraform and AWS CLI Environment

## Goal

Prepare your local environment by installing Terraform, AWS CLI, and the HashiCorp Terraform extension in VS Code, configuring AWS CLI, and confirming that all required tools are working correctly.

## Evidence

### Screenshot 1 — Terraform Version

![Screenshot 1](screenshots/a4-ss1.png)

---

### Screenshot 2 — AWS CLI Version

![Screenshot 2](screenshots/a4-ss2.png)

---

### Screenshot 3 — HashiCorp Terraform Extension

![Screenshot 3](screenshots/a4-ss3.png)

---

# Task 1 — Create the Modular Terraform Project

## Goal

Create the Terraform project and organize the AWS infrastructure into separate Network, EC2, and RDS modules.

The completed project structure must include the root Terraform files, all three module directories, and `user_data.sh`:

```text
terraform-aws-epicbook/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh
    └── rds/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Evidence

### Screenshot 4 — Modular Project Structure

![Screenshot 4](screenshots/a4-ss4.png)

---

# Task 2 — Build the Network Module

## Goal

Create a reusable Terraform network module containing the VPC, subnets, Internet Gateway, routing, and Security Groups required by EpicBook.

The network module must include:

- VPC: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private database subnet A: `10.0.2.0/24`
- Private database subnet B: `10.0.3.0/24`
- Private database subnets in different Availability Zones
- Internet Gateway
- Public route table and public-subnet association
- EC2 Security Group allowing SSH and HTTP
- RDS Security Group allowing MySQL port `3306` only from the EC2 Security Group
- Network module variables and outputs

## Evidence

### Screenshot 5 — VPC and Subnets

![Screenshot 5](screenshots/a4-ss5.png)

---

### Screenshot 6 — Internet Gateway and Public Routing

![Screenshot 6](screenshots/a4-ss6.png)

---

### Screenshot 7 — EC2 and RDS Security Groups

![Screenshot 7](screenshots/a4-ss7.png)

---

### Screenshot 8 — Network Module Outputs

![Screenshot 8](screenshots/a4-ss8.png)

---

# Task 3 — Build the EC2 Module and User Data Installation Script

## Goal

Create an EC2 module that launches the EpicBook application server inside the public subnet and automatically installs the required server software using EC2 user data.

The EC2 module must:

- Deploy the instance inside the public subnet
- Use the EC2 Security Group from the Network module
- Use a supported Ubuntu LTS AMI
- Assign a public IPv4 address
- Use an EC2 key pair for SSH authentication
- Connect `user_data.sh` through the EC2 `user_data` argument
- Expose the EC2 instance ID and public IP

The `user_data.sh` script must install the required software without storing database credentials or other secrets.

## Evidence

### Screenshot 9 — EC2 Resource and `user_data`

![Screenshot 9](screenshots/a4-ss9.png)

---

### Screenshot 10 — `user_data.sh`

![Screenshot 10](screenshots/a4-ss10.png)

---

### Screenshot 11 — EC2 Module Variables and Outputs

![Screenshot 11](screenshots/a4-ss11.png)

---

# Task 4 — Build the Amazon RDS Module

## Goal

Create an RDS module that provisions Amazon RDS for MySQL inside private database subnets.

The RDS module must include:

- A DB subnet group using both private database subnets
- Amazon RDS for MySQL
- RDS Security Group reference
- `publicly_accessible = false`
- Sensitive variables for database credentials
- RDS endpoint output
- No password output

## Evidence

### Screenshot 12 — DB Subnet Group and RDS MySQL

![Screenshot 12](screenshots/a4-ss12.png)

---

### Screenshot 13 — Private RDS and Sensitive Variables

![Screenshot 13](screenshots/a4-ss13.png)

---

### Screenshot 14 — RDS Endpoint Output

![Screenshot 14](screenshots/a4-ss14.png)

---

# Task 5 — Connect the Terraform Modules from the Root Module

## Goal

Use the root Terraform configuration to call the Network, EC2, and RDS modules and pass values between them.

## Evidence

### Screenshot 15 — Root Module Blocks

![Screenshot 15](screenshots/a4-ss15.png)

---

### Screenshot 16 — Values Passed Between Modules

![Screenshot 16](screenshots/a4-ss16.png)

---

### Screenshot 17 — Root Outputs

![Screenshot 17](screenshots/a4-ss17.png)

---

# Task 6 — Initialize, Validate, Plan, and Apply the Terraform Configuration

## Goal

Initialize the modular Terraform project, validate the configuration, review the execution plan, and provision the AWS infrastructure.

## Evidence

### Screenshot 18 — Terraform Initialization

![Screenshot 18](screenshots/a4-ss18.png)

---

### Screenshot 19 — Terraform Validation

![Screenshot 19](screenshots/a4-ss19.png)

---

### Screenshot 20 — Terraform Plan

![Screenshot 20](screenshots/a4-ss20.png)

---

### Screenshot 21 — Terraform Apply

![Screenshot 21](screenshots/a4-ss21.png)

---

### Screenshot 22 — Terraform Outputs

![Screenshot 22](screenshots/a4-ss22.png)

---

# Task 7 — Verify EC2, User Data, and Amazon RDS

## Goal

Verify that the EC2 and RDS resources were successfully provisioned and confirm that the EC2 user data script installed the required software.

## Evidence

### Screenshot 23 — EC2 Running

![Screenshot 23](screenshots/a4-ss23.png)

---

### Screenshot 24 — Private RDS Available

![Screenshot 24](screenshots/a4-ss24.png)

---

### Screenshot 25 — Installed Software and Nginx

![Screenshot 25](screenshots/a4-ss25.png)

---

# Task 8 — Prepare the EpicBook Database

## Goal

Connect from EC2 to Amazon RDS, create the EpicBook database, import the schema and seed data, and verify the database contents.

## Evidence

### Screenshot 26 — EC2-to-RDS Connection

![Screenshot 26](screenshots/a4-ss26.png)

---

### Screenshot 27 — EpicBook Tables and Imported Data

![Screenshot 27](screenshots/a4-ss27.png)

---

# Task 9 — Deploy and Configure the EpicBook Application

## Goal

Install EpicBook dependencies, configure the application to use Amazon RDS, configure Nginx as a reverse proxy, and start the application.

## Evidence

### Screenshot 28 — Dependencies and `node_modules`

![Screenshot 28](screenshots/a4-ss28.png)

---

### Screenshot 29 — Nginx Configuration and Service

![Screenshot 29](screenshots/a4-ss29.png)

---

### Screenshot 30 — EpicBook on Port `8080`

![Screenshot 30](screenshots/a4-ss30.png)

---

# Task 10 — Test End-to-End Functionality

## Goal

Verify that EpicBook, EC2, Nginx, and Amazon RDS work together successfully.

## EC2 Public IP URL

**EC2 Public IP URL:** http://56.69.30.161

## Evidence

### Screenshot 31 — EpicBook Through the EC2 Public IP

![Screenshot 31](screenshots/a4-ss31.png)

---

### Screenshot 32 — Cart or Checkout Action

![Screenshot 32](screenshots/a4-ss32.png)

---

### Screenshot 33 — Corresponding RDS Record

![Screenshot 33](screenshots/a4-ss33.png)

---

# Task 11 — Destroy the Terraform Infrastructure

## Goal

Remove all AWS resources created by the modular Terraform configuration.

## Evidence

### Screenshot 34 — Terraform Destroy

![Screenshot 34](screenshots/a4-ss34.png)

---

# Task 12 — LinkedIn Post (Mandatory)

## Goal

Share what you built and learned from the modular AWS Terraform deployment.

Write the post in your own words and include at least one deployment screenshot or other proof. Ensure that the post can be viewed by the submission reviewer.

## Evidence

### Screenshot 35 — Published LinkedIn Post

![Screenshot 35](screenshots/a4-ss35.png)

## LinkedIn Post URL

**LinkedIn Post URL:** https://www.linkedin.com/posts/javeson-francois-liu-999135437_dmibypravinmishra-devops-terraform-ugcPost-7529447755602268160-oFgf

---

# Notes

- Terminal screenshots (1, 2, 18 to 22, 23 to 30, 33, 34) were rendered as images from the real output of the same commands. The browser screenshots (31 and 32) and the VS Code Extensions screenshot (3) are direct captures.
- Screenshot 35 joins two captures of the same published post, the top part on the left and the bottom part with the attached deployment images on the right.
- Screenshot 20 lists the 13 planned resources and the outputs, without the long attribute blocks.
- Screenshot 21 combines two apply runs. The first created 11 resources and stopped on an existing DB subnet group name, so the module now uses `epicbook-terraform-db-subnet-group`. The second run created the RDS instance and finished with `Resources: 2 added`.
- The database password was generated locally, passed to Terraform through `TF_VAR_db_password`, and copied to the instance through SSH stdin into a file with mode 600. It is not in any file in this repository.
- The EC2 instance, RDS database, VPC and other resources were destroyed after verification, so the public IP in Task 10 no longer exists.

---

# Submission Instructions

- Complete Tasks 0–12 in sequence.
- Include all Screenshots 1–35 exactly as specified.
- Ensure that your full name is visible in the required screenshots.
- Include the working EpicBook EC2 public IP URL.
- Include the published LinkedIn post URL.
- Include proof of frontend, backend, and database integration.
- Ensure that the required Terraform root files, module files, and `user_data.sh` are included in the GitHub submission.
- Do not upload Terraform state files, `.pem` files, or a `terraform.tfvars` file containing passwords or other sensitive values.
- Do not expose AWS credentials, account IDs, private SSH keys, RDS passwords, access tokens, Terraform sensitive values, or other confidential information.
- Review all screenshots and files carefully before submitting through GitHub.

---

# Completion Checklist

- [x] Installed and verified Terraform
- [x] Installed and verified AWS CLI
- [x] Configured AWS CLI
- [x] Confirmed the AWS Region
- [x] Installed the HashiCorp Terraform extension
- [x] Created the modular Terraform project
- [x] Created the root `main.tf`, `variables.tf`, and `outputs.tf`
- [x] Created the Network module
- [x] Created the EC2 module
- [x] Created the RDS module
- [x] Created the EC2 `user_data.sh`
- [x] Created VPC `10.0.0.0/16`
- [x] Created public subnet `10.0.1.0/24`
- [x] Created private DB subnet A `10.0.2.0/24`
- [x] Created private DB subnet B `10.0.3.0/24`
- [x] Used different Availability Zones for the database subnets
- [x] Created and attached the Internet Gateway
- [x] Created the public route table
- [x] Associated the public subnet with the public route table
- [x] Created the EC2 Security Group
- [x] Allowed HTTP port `80`
- [x] Restricted SSH port `22`
- [x] Created the RDS Security Group
- [x] Allowed MySQL port `3306` from the EC2 Security Group only
- [x] Exposed the required Network module outputs
- [x] Defined the EC2 instance
- [x] Connected `user_data.sh` using the EC2 `user_data` argument
- [x] Configured EC2 with a public IP
- [x] Installed the required software using user data
- [x] Created the RDS DB subnet group
- [x] Created Amazon RDS for MySQL
- [x] Confirmed RDS is not publicly accessible
- [x] Configured sensitive database variables
- [x] Exposed the RDS endpoint
- [x] Connected all modules through the root module
- [x] Passed Network module outputs to EC2 and RDS
- [x] Added root EC2 public IP and RDS endpoint outputs
- [x] Completed `terraform init`
- [x] Completed `terraform validate`
- [x] Reviewed `terraform plan`
- [x] Completed `terraform apply`
- [x] Verified EC2 is running
- [x] Verified RDS is available
- [x] Verified user data installation
- [x] Connected to EC2 using SSH
- [x] Cloned EpicBook
- [x] Created the `bookstore` database
- [x] Imported the database schema
- [x] Imported author seed data
- [x] Imported book seed data
- [x] Verified database records
- [x] Installed EpicBook dependencies
- [x] Configured EpicBook to use RDS
- [x] Configured Nginx
- [x] Started EpicBook
- [x] Verified port `8080`
- [x] Loaded EpicBook through the EC2 public IP
- [x] Verified product viewing
- [x] Verified Add to Cart
- [ ] Verified the checkout or order workflow
- [x] Confirmed application actions in Amazon RDS
- [x] Completed `terraform destroy`
- [x] Published the required LinkedIn post
- [x] Added the LinkedIn post URL
- [x] Captured all 35 required screenshots
- [x] Confirmed that my full name is visible in the required screenshots
- [x] Checked that no sensitive information is exposed

---

## About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory), focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations through hands-on experience.

---

## Resources

- EpicBook Repository: [https://github.com/pravinmishraaws/theepicbook](https://github.com/pravinmishraaws/theepicbook)
- EpicBook Installation, Configuration & Troubleshooting Guide: [Installation & Configuration Guide](https://github.com/pravinmishraaws/theepicbook/blob/main/Installation%20%26%20Configuration%20Guide.md)
- DMI Official Website: [https://dmi.pravinmishra.com](https://dmi.pravinmishra.com)
- University: [https://university.pravinmishra.com](https://university.pravinmishra.com)
- Discord Community: [https://discord.pravinmishra.com](https://discord.pravinmishra.com)
- Blog: [https://dmi.pravinmishra.com/blog](https://dmi.pravinmishra.com/blog)
- YouTube Playlist: [https://www.youtube.com/playlist?list=PLFeSNDtI4Cho](https://www.youtube.com/playlist?list=PLFeSNDtI4Cho)
- Pravin Mishra on LinkedIn: [https://www.linkedin.com/in/pravin-mishra-aws-trainer/](https://www.linkedin.com/in/pravin-mishra-aws-trainer/)
- CloudAdvisory on LinkedIn: [https://www.linkedin.com/company/thecloudadvisory/](https://www.linkedin.com/company/thecloudadvisory/)

---

*This submission is part of the DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
