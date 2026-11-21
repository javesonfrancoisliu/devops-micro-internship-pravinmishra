# ansible-onboarding

Team-ready Ansible development workstation, set up by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 9.

This workspace is the Ansible controller used in the Week 9 assignments. Everything runs inside a Python virtual environment, so the system Python is never modified.

## Workstation Details

| Item | Value |
|---|---|
| Owner | Javeson Francois Liu |
| OS | macOS (Apple silicon) |
| Python | 3.14 in `.venv` |
| Ansible | ansible-core 2.22.0 (package 15.0.0) |
| Linters | ansible-lint 26.11.0, yamllint 1.38.0 |
| Git hooks | pre-commit 4.7.0 |
| SSH key | ED25519, dedicated key `id_ed25519_ansible` loaded in the SSH agent |
| Editor | VS Code with the Ansible, YAML and Python extensions |

## Project Structure

| Path | Purpose |
|---|---|
| `ansible.cfg` | Project defaults: inventory, roles path, SSH and connection settings |
| `requirements.txt` | Pinned Python tools so every machine gets the same versions |
| `.pre-commit-config.yaml` | Checks that run before every commit |
| `.yamllint` | YAML style rules |
| `.editorconfig` | Shared indentation and line-ending rules |
| `.vscode/settings.json` | Points VS Code at the project `.venv` and enables Ansible validation |
| `inventories/` | Host inventories |
| `playbooks/` | Playbooks |
| `roles/` | Reusable roles |

## New Machine? Do This

1. Install Python 3, Git and VS Code.
2. Clone this repository and open the folder in VS Code.
3. Create the environment: `python3 -m venv .venv`.
4. Activate it: `source .venv/bin/activate`.
5. Install the tools: `pip install -r requirements.txt`.
6. Check the versions: `ansible --version`, `ansible-lint --version`, `yamllint --version`.
7. Install the VS Code extensions: Ansible, YAML and Python.
8. Create an ED25519 key: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ansible`.
9. Load the key into the agent: `ssh-add ~/.ssh/id_ed25519_ansible`.
10. Set your Git identity: `git config user.name` and `git config user.email`.
11. Install the hooks: `pre-commit install`.
12. Prove it works: `pre-commit run --all-files`.

## Rules

- Never commit `.venv/`, SSH private keys, `.env` files or vault passwords. They are listed in `.gitignore`.
- Run Ansible from this folder so `ansible.cfg` is loaded.
- Commit only when `pre-commit` passes.
