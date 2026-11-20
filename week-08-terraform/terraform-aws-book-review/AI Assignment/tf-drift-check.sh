#!/usr/bin/env bash
set -uo pipefail

STUDENT_NAME="Javeson Francois Liu"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_DIR/reports"
PROFILE="${TF_DRIFT_PROFILE:-javesonpersonal}"
WORK_DIR="$REPORT_DIR/.work"
PLAN_BINARY="$WORK_DIR/plan.bin"
RAW_JSON="$WORK_DIR/plan-raw.json"
PLAN_ERRORS="$WORK_DIR/plan-errors.txt"
PLAN_JSON="$REPORT_DIR/tfplan.json"
LATEST_REPORT="$REPORT_DIR/latest-report.txt"
SAFE_INGRESS_PORTS='[80,443]'
checks=(check_destructive_actions check_open_ingress)

trap 'rm -rf "$WORK_DIR"' EXIT

mask_ids() {
  sed -E 's/[0-9]{12}/<acct>/g'
}

run_plan() {
  (cd "$PROJECT_DIR" && AWS_PROFILE="$PROFILE" terraform plan -detailed-exitcode -input=false -lock=false -no-color -out="$PLAN_BINARY" >/dev/null 2>"$PLAN_ERRORS")
}

sanitize_plan() {
  (cd "$PROJECT_DIR" && AWS_PROFILE="$PROFILE" terraform show -json "$PLAN_BINARY" >"$RAW_JSON")
  jq '{
    terraform_version,
    resource_changes: [
      .resource_changes[]?
      | select(.change.actions != ["no-op"])
      | {
          address,
          type,
          actions: .change.actions,
          ingress: (if .type == "aws_security_group" then (.change.after.ingress // []) else [] end)
        }
    ]
  }' "$RAW_JSON" >"$PLAN_JSON"
}

check_destructive_actions() {
  jq -r '.resource_changes[] | select(.actions | index("delete")) | "\(.address) will be deleted or replaced"' "$PLAN_JSON"
}

check_open_ingress() {
  jq -r --argjson safe "$SAFE_INGRESS_PORTS" '
    .resource_changes[]
    | select(.type == "aws_security_group")
    | .address as $address
    | .ingress[]
    | select(((.cidr_blocks // []) | index("0.0.0.0/0")) or ((.ipv6_cidr_blocks // []) | index("::/0")))
    | select((.protocol == "tcp" and .from_port == .to_port and (.from_port as $port | $safe | index($port))) | not)
    | "\($address) allows \(.protocol) \(.from_port)-\(.to_port) from the internet"
  ' "$PLAN_JSON"
}

collect_findings() {
  local check line
  for check in "${checks[@]}"; do
    while IFS= read -r line; do
      [ -n "$line" ] && findings+=("$check: $line")
    done < <("$check")
  done
}

print_report() {
  echo "Terraform Drift and Policy Review"
  echo "Reviewer: $STUDENT_NAME"
  echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "Terraform plan exit code: $plan_exit"
  case "$plan_exit" in
    0)
      echo "Pending changes: none"
      echo "Evidence: terraform plan -detailed-exitcode reported no differences, so no plan JSON was created"
      ;;
    2)
      echo "Pending changes:"
      jq -r '.resource_changes[] | "  - \(.address) [\(.actions | join(","))]"' "$PLAN_JSON"
      echo "Policy findings:"
      if [ "${#findings[@]}" -eq 0 ]; then
        echo "  - none"
      else
        printf '  - %s\n' "${findings[@]}"
      fi
      ;;
    *)
      echo "Terraform error:"
      head -n 5 "$PLAN_ERRORS" | sed 's/^/  /'
      ;;
  esac
  echo "Overall Status: $status"
}

findings=()
status="HEALTHY"
exit_code=0

mkdir -p "$WORK_DIR"
rm -f "$PLAN_JSON"

run_plan
plan_exit=$?

case "$plan_exit" in
  0) ;;
  2)
    sanitize_plan
    status="WARN"
    exit_code=1
    collect_findings
    if [ "${#findings[@]}" -gt 0 ]; then
      status="FAIL"
      exit_code=2
    fi
    ;;
  *)
    status="ERROR"
    exit_code=3
    ;;
esac

print_report | mask_ids | tee "$LATEST_REPORT"

if [ "${1:-}" != "" ]; then
  cp "$LATEST_REPORT" "$REPORT_DIR/$1"
fi

exit "$exit_code"
