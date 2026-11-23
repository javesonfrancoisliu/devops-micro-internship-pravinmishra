# Owner steps: Week 10 Assignments 02 to 05

Prepared for Javeson Francois Liu. Everything under `work/a02` to `work/a05` is validated offline. This list holds only what needs the portal, a secret, `terraform apply` or a pipeline run. Do the steps in order inside each assignment.

Azure DevOps organization `javeson-dmi`, project `dmi-week10`, pool `self-hosted-linux`, agent `dmi-agent-01`.

## Step 0: once, for A02 to A04

1. Create a dedicated RSA key without passphrase (the Azure DevOps SSH task supports RSA best):
   `ssh-keygen -t rsa -b 4096 -m PEM -N "" -f ~/.ssh/id_rsa_dmi_azdo`
2. Confirm the agent is Online and its public IP is still `43.216.135.239`. If the agent VM was stopped and started the IP changed: update `agent_ip` in the A02 and A03 `terraform.tfvars` and `agentPublicIp` in the A04 infra YAML.
3. Your Mac public IP changes: set the current one as `controller_ip` in each `terraform.tfvars`.
4. A leftover instance `docker-static-site` (t3.micro) is still running in `ap-southeast-5` from Week 11. Stop it if no longer needed.

## A02: static website (screenshots 1 to 5, URL, LinkedIn)

1. Repos > Import repository: `https://github.com/pravinmishraaws/Azure-Static-Website`, name `azure-static-website`.
2. Replace `index.html` with `work/a02/repo/index.html` (full name already added) and commit. **Screenshot 1**: repo files with `index.html`.
3. `cd work/a02/terraform`, copy `terraform.tfvars.example` to `terraform.tfvars`, set `controller_ip` and `agent_ip`, then `terraform init`, `terraform plan`, `terraform apply` (owner only). Plan shows 3 to add.
4. `cd ../ansible`, copy `inventory.ini.example` to `inventory.ini`, set the new `public_ip`, then `ansible web -m ping` and `ansible-playbook site.yml` (use the Week 9 environment, `requirements.txt` there).
5. Project settings > Service connections > New > SSH: host = public IP, port 22, user `ubuntu`, private key = contents of `~/.ssh/id_rsa_dmi_azdo`, name `ubuntu-nginx-ssh`, tick Grant access permission to all pipelines. **Screenshot 2**: connection Overview page.
6. Add `work/a02/repo/azure-pipelines.yml` to the repo root in the Repos editor. **Screenshot 3**: the YAML open in the editor.
7. Pipelines > New pipeline > Azure Repos Git > `azure-static-website` > Existing YAML. Run it. Click Permit if it asks for the pool or the connection. **Screenshot 4**: run Succeeded with the three steps and the full name in the log.
8. Edit `index.html` text (for example the footer) and commit to any branch: a second run starts by itself. **Screenshot 5**: browser on `http://<public_ip>` showing the full name and the new text. Paste the URL in the markdown.
9. LinkedIn post (draft below), screenshot and URL.

## A03: React app (screenshots 1 to 8, LinkedIn)

Do A02 evidence first: step 3 below repoints the shared connection.

1. Import `https://github.com/pravinmishraaws/my-react-app` as `my-react-app`. **Screenshot 1**: `package.json` and `src/` visible.
2. Replace `src/App.js` with `work/a03/repo/src/App.js` (name and date; the date is 23/11/2026, change it to the day you deploy). Do not add the pipeline YAML yet.
3. `cd work/a03/terraform`: same `terraform.tfvars`, `init`, `plan`, `apply` (owner only). **Screenshot 2**: apply output with the public IP.
4. `cd ../ansible`: copy and fill `inventory.ini`, run `ansible-playbook site.yml`. **Screenshot 3**: PLAY RECAP with `failed=0` and Nginx active.
5. Edit service connection `ubuntu-nginx-ssh`: host = new public IP, re-paste the private key, save. **Screenshot 4**: connection page, key hidden.
6. Add `work/a03/repo/azure-pipelines.yml` to the repo root and commit to `main` (this push triggers the first run). **Screenshot 5**: YAML with four stages. Create the pipeline from the Existing YAML option; click Permit if asked.
7. **Screenshot 6**: run summary with Build, Test, Publish, Deploy green. **Screenshot 7**: Deploy log step showing `ls -la /var/www/html`. **Screenshot 8**: browser on `http://<public_ip>`.
8. LinkedIn post, screenshot and URL.

## A04: dual pipelines (screenshots 1 to 7, notes, LinkedIn)

Cost warning: two `Standard_B2ls_v2` VMs, one MySQL `B_Standard_B1ms`, two public IPs, roughly USD 2 to 3 per day. Destroy after grading (step 12).

1. Azure CLI as you (writes to Azure, owner only):
   - `az group create -n rg-dmi-tfstate -l swedencentral`
   - `az storage account create -n stdmitfstatejfl01 -g rg-dmi-tfstate -l swedencentral --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false`
   - `az storage container create --account-name stdmitfstatejfl01 -n tfstate --auth-mode login`
   - `az provider register --namespace Microsoft.DBforMySQL` and the same for `Microsoft.Network`, `Microsoft.Compute`, `Microsoft.Storage`.
   - `az ad sp create-for-rbac --name sp-dmi-week10-epicbook --role Contributor --scopes /subscriptions/<subscription-id>` prints the Client Secret once. Keep it out of screenshots and chat.
   - If the storage account name is taken, change it in the infra YAML (`tfstateStorageAccount`).
2. Create repo `infra-epicbook` and push the files of `work/a04/infra-epicbook`. Import `https://github.com/pravinmishraaws/theepicbook` as `theepicbook`, then add the folder `work/a04/theepicbook/ansible` and `work/a04/theepicbook/azure-pipelines.yml`. **Screenshot 1**: both repos side by side.
3. Pipelines > Library > Variable group `epicbook-secrets`: `MYSQL_ADMIN_PASSWORD` (secret, 16 to 64 letters and digits only) and `SSH_PUBLIC_KEY` (contents of `~/.ssh/id_rsa_dmi_azdo.pub`). Allow all pipelines.
4. Pipelines > Library > Secure files: upload `~/.ssh/id_rsa_dmi_azdo` named `epicbook_ssh_key`, allow all pipelines.
5. Service connection > Azure Resource Manager > Service principal (manual): Tenant ID, Subscription ID, Client ID, Client Secret from step 1, name `azure-spn-epicbook`, Verify, Save. **Screenshot 2**: Overview, secrets hidden.
6. Pipelines > New pipeline > `infra-epicbook` > Existing YAML. Run with action `apply` on `main`; Permit the variable group, connection and pool when asked. If it fails on VM size or zone in `swedencentral`, change `vm_size` or `zone` defaults and run again.
7. **Screenshot 3**: log with apply complete and the outputs `app_public_ip` and `mysql_fqdn`. **Screenshot 4**: Azure Portal resource group `rg-epicbook`.
8. On pipeline `theepicbook` (create it from Existing YAML first) add variables `APP_PUBLIC_IP` and `MYSQL_FQDN` with the output values (not secret).
9. Run `theepicbook`. Permit the secure file and variable group. **Screenshot 5**: run summary Succeeded. **Screenshot 6**: playbook recap with `failed=0`.
10. **Screenshot 7**: browser on `http://<app_public_ip>` showing EpicBook with books. Write the URL and any issue and fix in Notes.
11. LinkedIn post, screenshot and URL.
12. After grading: run `infra-epicbook` with action `destroy`.

## A05: AI triage skill (screenshots 1 to 10, notes done)

Needs A04 finished so both pipelines exist.

1. Copy `work/a05` to a working folder, for example `week-10-azure-devops/pipeline-triage`. Keep the scripts executable.
2. `az extension add --name azure-devops`. Create a PAT with read scope for Build and Project (portal, owner only) and sign in with `az devops login --organization https://dev.azure.com/javeson-dmi` so the token is typed into the prompt, never into a file or screenshot.
3. **Screenshot 1**: both pipelines Succeeded (GitHub Actions is optional: set `GH_REPO` only if you have a repo).
4. **Screenshot 2**: `CLAUDE.md`. **Screenshot 3**: `pipeline-triage.sh`. Run `./pipeline-triage.sh --self-test` first (8 PASS plus AUDIT PASS).
5. **Screenshot 4**: `./pipeline-triage.sh` on the healthy pipelines.
6. Open Claude Code in the folder. **Screenshot 5**: `SKILL.md` frontmatter. **Screenshot 6**: `/pipeline-triage` healthy output.
7. Break safely in `theepicbook`: change `nodejs` to `nodejss` in `ansible/group_vars/backend.yml`, push. **Screenshot 7**: failed run. **Screenshot 8**: `/pipeline-triage` shows dependency, quotes `No package matching 'nodejss' is available`, recommends the fix.
8. Fix it yourself, push. **Screenshot 9**: green run. **Screenshot 10**: `/pipeline-triage` healthy again.

The live `az devops invoke` calls in `pipeline-triage.sh` could not be run offline. The first real run may need a small adjustment to a flag or JSON field; the classification logic is already tested.

## LinkedIn drafts

A02: I automated a website deployment with Terraform, Ansible and Azure DevOps. Terraform built the EC2 server, Ansible prepared Nginx, and an Azure Pipelines YAML on my self-hosted agent copies the site over SSH and checks it. Every push now updates the live page. Built by Javeson Francois Liu, DevOps Micro Internship.

A03: My React app now deploys itself. A push to main runs Build, Test, Publish and Deploy in Azure Pipelines on my self-hosted agent. A failing test stops the release, and only the tested build reaches the Nginx server. Javeson Francois Liu, DevOps Micro Internship.

A04: Two repositories, two pipelines. infra-epicbook uses Terraform to build the Azure network, two VMs and a private MySQL server. theepicbook uses Ansible to configure them and deploy EpicBook behind Nginx. Check: the home page lists books read from MySQL. Javeson Francois Liu, DevOps Micro Internship.
