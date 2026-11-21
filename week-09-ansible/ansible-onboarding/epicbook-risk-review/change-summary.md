# Change Summary

**Author:** Javeson Francois Liu
**Date:** 2026-11-21
**Target:** `epicbook-web` (EpicBook on AWS, `ap-southeast-5`)

## Change

Added one task to the `nginx` role: `Restart Nginx to apply tuning` (`ansible.builtin.service`, `state: restarted`).

## Risk review before applying

- Dry run: `./ansible-check-review.sh` (`--check --diff`, nothing applied).
- Result: `WARNING`, exit code 1, 1 changed task, ok=14 changed=1 failed=0.
- Category: Service disruption. Evidence: `reports/risky-change-report.txt`.
- Claude Code `/ansible-risk-review` agreed and advised changing the task to the existing `Reload Nginx` handler, or applying in a low-traffic window.
- Not evaluated: 9 `command` and `shell` tasks skipped in check mode.

## Decision

I read the report and decided to apply it as a controlled test on a lab VM. Claude Code did not apply anything. I ran the real playbook manually:

`ansible-playbook -i inventory.ini site.yml`

## Result after applying

- Recap: ok=20 changed=1 unreachable=0 failed=0 skipped=3.
- Only the restart task changed. Every other task was `ok`.
- `ansible web -i inventory.ini -m ping` returned `SUCCESS` and `http://43.216.199.75` returned HTTP 200.
- A second review (`reports/post-apply-report.txt`) still flags the restart, because a restart always reports `changed`.

## Follow-up

- Replace the unconditional restart with the `Reload Nginx` handler, or remove it, so the playbook is idempotent again.
- Extend the review to show skipped tasks by name.
