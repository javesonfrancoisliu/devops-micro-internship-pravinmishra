# Assignment 01 — Set Up a Team-Ready Ansible Development Workstation

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will prepare an isolated and reusable Ansible development workstation.

You will install Ansible and supporting tools inside a Python virtual environment, configure VS Code, prepare SSH access, configure Git and pre-commit hooks, and document the complete setup.

This workstation will be used as the Ansible controller in upcoming assignments.

---

# Task 1 — Create and Initialize the Ansible Workspace

## Goal

Create the assignment workspace, initialize a Git repository, prepare the required directories, and add Git ignore rules for local and sensitive files.

### Evidence

#### Screenshot 1 — Terminal showing the `ansible-onboarding` path, `ls -la` output, and `git status` confirming the Git repository is on the `main` branch

![Screenshot 1](screenshots/a1-ss1.png)

---

# Task 2 — Create the Virtual Environment and Install Ansible Tools

## Goal

Create an isolated Python virtual environment and install Ansible and the required validation tools without modifying the system Python environment.

### Evidence

#### Screenshot 2 — Terminal showing the active `(.venv)` environment, `which ansible`, `ansible --version`, `ansible-lint --version`, `yamllint --version`, and `pre-commit --version`

![Screenshot 2](screenshots/a1-ss2.png)

---

# Task 3 — Configure VS Code for Ansible Development

## Goal

Configure Visual Studio Code to use the project’s Python virtual environment and provide validation support for Python, YAML, and Ansible files.

### Evidence

#### Screenshot 3 — VS Code Extensions panel showing the Ansible, YAML, and Python extensions installed

![Screenshot 3](screenshots/a1-ss3.png)

---

#### Screenshot 4 — VS Code showing `.vscode/settings.json` and `.editorconfig` open side by side, with the required settings clearly visible

![Screenshot 4](screenshots/a1-ss4.png)

---

# Task 4 — Create the Baseline Ansible Configuration

## Goal

Create a reusable `ansible.cfg` file containing the default settings that will be used in this workspace and upcoming Ansible assignments.

### Evidence

#### Screenshot 5 — `ansible.cfg` open in VS Code or another editor, showing the complete configuration

![Screenshot 5](screenshots/a1-ss5.png)

---

#### Screenshot 6 — Terminal showing `ansible --version` with the `ansible.cfg` path and the output of `ansible-config dump --only-changed`

![Screenshot 6](screenshots/a1-ss6.png)

---

# Task 5 — Configure SSH Readiness

## Goal

Prepare SSH key authentication, load the key into the SSH agent, configure reusable SSH client settings, and understand how trusted host fingerprints are stored.

### Evidence

#### Screenshot 7 — Terminal showing `ssh-add -l` with the ED25519 key loaded and the SSH configuration verification output

![Screenshot 7](screenshots/a1-ss7.png)

---

# Task 6 — Configure Git Identity and Pre-commit Hooks

## Goal

Configure your Git identity and install pre-commit hooks that validate YAML and Ansible files before commits are created.

### Evidence

#### Screenshot 8 — Terminal showing your Git full name, Git email, default branch, successful `pre-commit install` output, and `.git/hooks/pre-commit`

![Screenshot 8](screenshots/a1-ss8.png)

---

# Task 7 — Test the Complete Workstation Setup

## Goal

Verify that Ansible, the linting tools, Git hooks, SSH agent, and Git ignore rules are working correctly.

### Evidence

#### Screenshot 9 — Terminal showing `pre-commit run --all-files` completing successfully

![Screenshot 9](screenshots/a1-ss9.png)

---

#### Screenshot 10 — Terminal showing `ansible --version` with the project configuration path and `ssh-add -l` with the ED25519 key loaded

![Screenshot 10](screenshots/a1-ss10.png)

---

# Task 8 — Create the README and Onboarding Checklist

## Goal

Document the completed Ansible workstation setup and create a reusable checklist for preparing another workstation in the future.

### Evidence

#### Screenshot 11 — Terminal showing the final `ansible-onboarding` project structure

![Screenshot 11](screenshots/a1-ss11.png)

---

#### Screenshot 12 — VS Code Markdown preview showing your full name, project summary, and part of the “New Machine? Do This” checklist

![Screenshot 12](screenshots/a1-ss12.png)

---

# Assignment Questions

Answer the following in your own words:

**1. What is one feature that makes your workstation setup team-friendly?**

The pinned `requirements.txt` plus the "New Machine? Do This" checklist in the README. Anyone who clones the repo gets the same Ansible and linter versions by following 12 steps, and the pre-commit hooks make everyone's commits pass the same checks.

---

**2. What is one pitfall you avoided while completing the setup?**

I avoided reusing my existing SSH key. I created a dedicated ED25519 key, `id_ed25519_ansible`, with a passphrase and a scoped `ansible-*` block in `~/.ssh/config`, so I can revoke it later without touching my other access. I also noticed that `IdentitiesOnly` still offers my old key because the global `Host *` block lists it.

---

**3. Why should Ansible be installed inside a Python virtual environment?**

A virtual environment keeps Ansible and its Python packages separate from the system Python and from other projects. It makes the versions reproducible from `requirements.txt`, avoids dependency conflicts, and can be deleted and rebuilt in minutes without breaking anything else on the Mac.

---

**4. Why must SSH private keys and `.venv/` remain outside version control?**

A private key is my identity: anyone who gets it can log in to my servers, and Git history keeps it forever even after a delete. `.venv/` is large, machine-specific, contains absolute paths, and can always be rebuilt from `requirements.txt`, so it adds noise and no value to the repository.

---

# Required Files

Confirm that the following files are included in your assignment workspace:

- [x] `README.md`
- [x] `requirements.txt`
- [x] `.gitignore`
- [x] `.editorconfig`
- [x] `.vscode/settings.json`
- [x] `ansible.cfg`
- [x] `.pre-commit-config.yaml`
- [x] `inventories/`
- [x] `roles/`

---

# Submission Instructions

- Add all required screenshots in your submission.
- Full Name must be visible in required screenshots.
- All screenshots must be readable.
- Answer all assignment questions clearly in your own words.
- Do not expose SSH private-key contents, passwords, access tokens, API keys, credentials, private certificates, or other sensitive information.

---

# Completion Checklist

- [x] Task 1: `ansible-onboarding` workspace created
- [x] Task 1: Git initialized on the `main` branch
- [x] Task 1: `.gitignore` created
- [x] Task 2: Python virtual environment created
- [x] Task 2: Virtual environment activated
- [x] Task 2: Ansible installed inside `.venv`
- [x] Task 2: `ansible-lint`, `yamllint`, and `pre-commit` installed
- [x] Task 2: `requirements.txt` created
- [x] Task 3: Required VS Code extensions installed
- [x] Task 3: VS Code uses the Python interpreter from `.venv`
- [x] Task 3: `.vscode/settings.json` created
- [x] Task 3: `.editorconfig` created
- [x] Task 4: `ansible.cfg` created
- [x] Task 4: Ansible loads `ansible.cfg` from the project directory
- [x] Task 5: ED25519 SSH key exists
- [x] Task 5: SSH private key has not been exposed
- [x] Task 5: SSH key loaded into the SSH agent
- [x] Task 5: `~/.ssh/config` contains the required settings
- [x] Task 5: `~/.ssh/known_hosts` exists
- [x] Task 6: Git identity configured correctly
- [x] Task 6: Pre-commit hooks installed
- [x] Task 7: `pre-commit run --all-files` completes successfully
- [x] Task 8: `README.md` contains your full name and workstation details
- [x] Task 8: “New Machine? Do This” checklist contains 10–12 items
- [x] All 12 required screenshots are included
- [x] Assignment questions are answered
- [x] No sensitive information is exposed

---

## About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra and The CloudAdvisory, focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## Resources

- DMI Official Website: [https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme](https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme)
- University: [https://university.pravinmishra.com?utm_source=github&utm_medium=readme](https://university.pravinmishra.com?utm_source=github&utm_medium=readme)
- Discord Community: [https://discord.pravinmishra.com?utm_source=github&utm_medium=readme](https://discord.pravinmishra.com?utm_source=github&utm_medium=readme)
- Blog: [https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme](https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme)
- YouTube Playlist: [https://www.youtube.com/playlist?list=PLFeSNDtI4Cho](https://www.youtube.com/playlist?list=PLFeSNDtI4Cho)
- Pravin Mishra LinkedIn: [https://www.linkedin.com/in/pravin-mishra-aws-trainer/](https://www.linkedin.com/in/pravin-mishra-aws-trainer/)
- CloudAdvisory LinkedIn: [https://www.linkedin.com/company/thecloudadvisory/](https://www.linkedin.com/company/thecloudadvisory/)

---

*This submission is part of DevOps Micro Internship (DMI) — Agentic AI Track.*