#!/usr/bin/env bash
set -o pipefail

full_name="Javeson Francois Liu"
playbook_path="ansible/site.yml"
inventory_path="ansible/inventory.ini"
report_file="${1:-reports/ansible-risk-report.txt}"
work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

checks=(
  "Destructive|remove|delete|purge|drop|wipe|erase|absent"
  "Service disruption|restart|stop|reload|reboot|shutdown|kill"
  "Security and access|user|group|ssh|sudo|firewall|ufw|iptables|permission|chmod|chown|password|key"
  "Package and config drift|install|upgrade|template|copy|lineinfile|config"
)

export ANSIBLE_CONFIG="$work_dir/ansible/ansible.cfg"
export ANSIBLE_VAULT_PASSWORD_FILE="$work_dir/ansible/.vault_pass"
export ANSIBLE_NOCOLOR=1
export ANSIBLE_FORCE_COLOR=0

run_dry_run() {
  ansible-playbook -i "$inventory_path" "$playbook_path" --check --diff 2>&1
}

extract_changed_tasks() {
  awk '
    /^(TASK|RUNNING HANDLER) \[/ { task = $0; sub(/^(TASK|RUNNING HANDLER) \[/, "", task); sub(/\] \*+$/, "", task) }
    /^changed: \[/ { print task }
  ' <<<"$1" | sort -u
}

check_tasks_matching_pattern() {
  local pattern="$1"
  local task
  for task in "${changed_tasks[@]}"; do
    if grep -Eiq "$pattern" <<<"$task"; then
      printf '%s\n' "$task"
    fi
  done
}

cd "$work_dir" || exit 2
mkdir -p "$(dirname "$report_file")"

output="$(run_dry_run)"
ansible_exit=$?

changed_tasks=()
while IFS= read -r line; do
  [ -n "$line" ] && changed_tasks+=("$line")
done < <(extract_changed_tasks "$output")

recap="$(grep -A1 'PLAY RECAP' <<<"$output" | tail -1)"
skipped="$(grep -o 'skipped=[0-9]*' <<<"$recap" | cut -d= -f2)"
risky_total=0
findings=""

for entry in "${checks[@]}"; do
  label="${entry%%|*}"
  pattern="${entry#*|}"
  matches="$(check_tasks_matching_pattern "$pattern")"
  if [ -n "$matches" ]; then
    count="$(grep -c . <<<"$matches")"
    risky_total=$((risky_total + count))
    findings+="[FLAGGED] $label ($count)"$'\n'
    while IFS= read -r task; do
      findings+="    - $task"$'\n'
    done <<<"$matches"
  else
    findings+="[clear]   $label (0)"$'\n'
  fi
done

if [ "$ansible_exit" -ne 0 ]; then
  status="FAILED"
  meaning="2 = the dry run itself failed, fix Ansible before reviewing"
  code=2
elif [ "$risky_total" -gt 0 ]; then
  status="WARNING"
  meaning="1 = risky changed tasks found, a human must review before applying"
  code=1
else
  status="HEALTHY"
  meaning="0 = no risky changed tasks"
  code=0
fi

{
  echo "Ansible change risk review"
  echo "Reviewer: $full_name"
  echo "Date: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "Playbook: $playbook_path"
  echo "Inventory: $inventory_path"
  echo "Mode: --check --diff (nothing was applied)"
  echo
  echo "Dry run recap: $recap"
  echo "Changed tasks: ${#changed_tasks[@]}"
  echo "Skipped in check mode (not evaluated): $skipped"
  for task in "${changed_tasks[@]}"; do
    echo "    - $task"
  done
  echo
  echo "Risk categories"
  printf '%s' "$findings"
  echo
  echo "Overall status: $status"
  echo "Exit code: $meaning"
} | tee "$report_file"

if [ "$status" = "FAILED" ]; then
  echo
  echo "$output" | tail -20
fi

exit "$code"
