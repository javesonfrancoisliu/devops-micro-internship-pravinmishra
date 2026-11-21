# static-web

A multi-play Ansible playbook that installs Nginx on two Ubuntu servers, deploys a static website, and checks that both servers answer with HTTP 200. Built by **Javeson Francois Liu** for the DevOps Micro Internship (DMI), Week 9, Assignment 03.

## What it does

| Play | Hosts | Job |
|---|---|---|
| 1 - Install and start Nginx | `web` | Installs Nginx with `apt`, then starts and enables it |
| 2 - Deploy the static website | `web` | Copies `files/index.html` to `/var/www/html` and reloads Nginx only when the file changed |
| 3 - Verify both web servers | `localhost` | Calls each server with the `uri` module and requires HTTP 200 |

## Files

| Path | Purpose |
|---|---|
| `inventory.ini` | The two servers, `web1` and `web2`, in the `web` group |
| `site.yml` | The three-play playbook |
| `files/index.html` | The website, with my full name in the footer |
| `ansible.cfg` | Points Ansible at `inventory.ini` |
| `terraform/` | Builds the two AWS servers (optional, for a repeatable lab) |

## How to run

1. Put the two public IPs into `inventory.ini`.
2. Check the connection: `ansible web -m ping`.
3. Check the syntax: `ansible-playbook site.yml --syntax-check`.
4. Deploy: `ansible-playbook site.yml`.
5. Run it again. A second run must show `changed=0` for both web servers.
6. Test by hand: `curl -I http://<server-ip>`.

## What I learned

- One playbook can hold several plays, so install, deploy and verify stay separate and easy to read.
- The `copy` module only reports a change when the file differs, so a re-run is safe. This is idempotency.
- A handler runs only when a task notifies it. The Nginx reload happens on the first run and not on the second.
- The `uri` module turns "the site looks fine" into a check that fails the run if a server does not return 200.
- Verifying from the controller tests the same path a visitor uses.
