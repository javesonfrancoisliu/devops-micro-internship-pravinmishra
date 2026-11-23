#!/usr/bin/env bash
set -uo pipefail

CONTEXT="${KUBE_CONTEXT:-kind-w12-c}"
NAMESPACE="${1:-bookreview}"
OWNER="Javeson Francois Liu"
REPORT_DIR="reports"
EVENT_WINDOW_MIN="${EVENT_WINDOW_MIN:-15}"
RESTART_FAIL_AT=5
PASS=0
WARN=0
FAIL=0
LINES=()

kc() {
  kubectl --context "$CONTEXT" -n "$NAMESPACE" "$@"
}

record() {
  local level="$1" check="$2" evidence="$3"
  LINES+=("[$level] $check: $evidence")
  case "$level" in
    PASS) PASS=$((PASS + 1)) ;;
    WARN) WARN=$((WARN + 1)) ;;
    FAIL) FAIL=$((FAIL + 1)) ;;
  esac
}

to_epoch() {
  date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null || date -u -d "$1" +%s 2>/dev/null
}

check_pod_status() {
  local rows bad
  rows=$(kc get pods --no-headers -o custom-columns='NAME:.metadata.name,PHASE:.status.phase,WAITING:.status.containerStatuses[*].state.waiting.reason' 2>&1) || {
    record FAIL "1 pod status" "kubectl get pods failed: $rows"
    return
  }
  if [ -z "$rows" ]; then
    record FAIL "1 pod status" "no pods in namespace $NAMESPACE"
    return
  fi
  bad=$(echo "$rows" | awk '{w=$3; gsub(/<none>|,/, "", w); if ($2 != "Running" || w != "") print $1, $2, (w == "" ? "none" : w)}')
  if [ -n "$bad" ]; then
    record FAIL "1 pod status" "$(echo "$bad" | awk '{printf "%s phase=%s waiting=%s; ", $1, $2, $3}')"
  else
    record PASS "1 pod status" "$(echo "$rows" | wc -l | tr -d ' ') pods, all Running"
  fi
}

check_pod_readiness() {
  local rows bad
  rows=$(kc get pods --no-headers 2>&1) || {
    record FAIL "2 pod readiness" "kubectl get pods failed: $rows"
    return
  }
  bad=$(echo "$rows" | awk '{split($2, r, "/"); if (r[1] != r[2]) print $1, "READY", $2}')
  if [ -n "$bad" ]; then
    record FAIL "2 pod readiness" "$(echo "$bad" | awk '{printf "%s %s %s; ", $1, $2, $3}')"
  else
    record PASS "2 pod readiness" "every container in every pod is Ready"
  fi
}

check_restarts() {
  local rows worst warn_list fail_list
  rows=$(kc get pods --no-headers -o custom-columns='NAME:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount' 2>&1) || {
    record FAIL "3 restart counts" "kubectl get pods failed: $rows"
    return
  }
  worst=$(echo "$rows" | awk '{n=split($2, c, ","); t=0; for (i=1;i<=n;i++) if (c[i] != "<none>") t+=c[i]; if (t>m) m=t} END {print m+0}')
  fail_list=$(echo "$rows" | awk -v lim="$RESTART_FAIL_AT" '{n=split($2, c, ","); t=0; for (i=1;i<=n;i++) if (c[i] != "<none>") t+=c[i]; if (t>=lim) printf "%s restarts=%d; ", $1, t}')
  warn_list=$(echo "$rows" | awk -v lim="$RESTART_FAIL_AT" '{n=split($2, c, ","); t=0; for (i=1;i<=n;i++) if (c[i] != "<none>") t+=c[i]; if (t>0 && t<lim) printf "%s restarts=%d; ", $1, t}')
  if [ -n "$fail_list" ]; then
    record FAIL "3 restart counts" "$fail_list"
  elif [ -n "$warn_list" ]; then
    record WARN "3 restart counts" "$warn_list"
  else
    record PASS "3 restart counts" "no container has restarted (max $worst)"
  fi
}

check_events() {
  local rows now recent=""
  now=$(date -u +%s)
  rows=$(kc get events --field-selector type=Warning --no-headers -o custom-columns='TIME:.lastTimestamp,REASON:.reason,OBJECT:.involvedObject.name,MESSAGE:.message' 2>&1) || {
    record FAIL "4 recent events" "kubectl get events failed: $rows"
    return
  }
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in "No resources found"*) continue ;; esac
    local ts epoch
    ts=$(echo "$line" | awk '{print $1}')
    epoch=$(to_epoch "$ts")
    if [ -n "$epoch" ] && [ $((now - epoch)) -le $((EVENT_WINDOW_MIN * 60)) ]; then
      recent+="$(echo "$line" | cut -d' ' -f2- | LC_ALL=C tr -d '\000-\037\177'); "
    fi
  done <<< "$rows"
  if [ -n "$recent" ]; then
    record WARN "4 recent events" "Warning events in the last ${EVENT_WINDOW_MIN} min: ${recent:0:600}"
  else
    record PASS "4 recent events" "no Warning events in the last ${EVENT_WINDOW_MIN} min"
  fi
}

check_endpoints() {
  local services svc ready empty="" ok=0
  services=$(kc get services --no-headers -o custom-columns='NAME:.metadata.name,SELECTOR:.spec.selector' 2>&1) || {
    record FAIL "5 service endpoints" "kubectl get services failed: $services"
    return
  }
  while read -r svc selector; do
    [ -z "$svc" ] && continue
    [ "$selector" = "<none>" ] && continue
    ready=$(kc get endpointslices -l "kubernetes.io/service-name=$svc" -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' 2>/dev/null | grep -c .)
    if [ "$ready" -eq 0 ]; then
      empty+="$svc has 0 ready endpoints; "
    else
      ok=$((ok + 1))
    fi
  done <<< "$services"
  if [ -n "$empty" ]; then
    record FAIL "5 service endpoints" "$empty($ok services have endpoints)"
  else
    record PASS "5 service endpoints" "all $ok services have ready endpoints"
  fi
}

write_report() {
  local stamp file overall
  stamp=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$REPORT_DIR"
  file="$REPORT_DIR/triage-${NAMESPACE}-${stamp}.txt"
  if [ "$FAIL" -gt 0 ]; then overall=FAIL; elif [ "$WARN" -gt 0 ]; then overall=WARN; else overall=PASS; fi
  {
    echo "Kubernetes triage report"
    echo "Owner: $OWNER"
    echo "Context: $CONTEXT  Namespace: $NAMESPACE"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "----------------------------------------"
    printf '%s\n' "${LINES[@]}"
    echo "----------------------------------------"
    echo "Summary: $PASS passed, $WARN warnings, $FAIL failures"
    echo "Overall: $overall"
    echo "Report file: $file"
  } | tee "$file"
  case "$overall" in
    PASS) return 0 ;;
    WARN) return 1 ;;
    *) return 2 ;;
  esac
}

if ! kubectl --context "$CONTEXT" get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Cannot reach namespace $NAMESPACE with context $CONTEXT" >&2
  exit 3
fi

check_pod_status
check_pod_readiness
check_restarts
check_events
check_endpoints
write_report
