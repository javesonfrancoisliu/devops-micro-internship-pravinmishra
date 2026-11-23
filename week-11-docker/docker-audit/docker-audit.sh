#!/usr/bin/env bash
set -uo pipefail

TARGET="${1:-}"
OWNER="Javeson Francois Liu"
REPORT_DIR="reports"
PASS=0
WARN=0
FAIL=0
LINES=()

record() {
  local level="$1" check="$2" evidence="$3"
  LINES+=("[$level] $check: $evidence")
  case "$level" in
    PASS) PASS=$((PASS + 1)) ;;
    WARN) WARN=$((WARN + 1)) ;;
    FAIL) FAIL=$((FAIL + 1)) ;;
  esac
}

check_exists() {
  if docker inspect "$TARGET" >/dev/null 2>&1; then
    local state
    state=$(docker inspect -f '{{.State.Status}}' "$TARGET")
    record PASS "1 container exists" "$TARGET is $state"
    return 0
  fi
  record FAIL "1 container exists" "no container named $TARGET"
  return 1
}

check_root_user() {
  local user
  user=$(docker inspect -f '{{.Config.User}}' "$TARGET")
  case "$user" in
    ""|root|0|0:*|root:*) record FAIL "2 runs as root" "Config.User is '${user:-empty}', processes run as root" ;;
    *) record PASS "2 runs as root" "Config.User is '$user'" ;;
  esac
}

check_healthcheck() {
  local defined
  defined=$(docker inspect -f '{{if .Config.Healthcheck}}yes{{else}}no{{end}}' "$TARGET")
  if [ "$defined" = yes ]; then
    local test
    test=$(docker inspect -f '{{json .Config.Healthcheck.Test}}' "$TARGET")
    record PASS "3 healthcheck defined" "$test"
  else
    record WARN "3 healthcheck defined" "no HEALTHCHECK in image or compose"
  fi
}

check_image_tag() {
  local image tag
  image=$(docker inspect -f '{{.Config.Image}}' "$TARGET")
  case "$image" in
    *@sha256:*) record PASS "4 image tag pinned" "$image (digest)"; return ;;
  esac
  tag="${image##*:}"
  if [ "$tag" = "$image" ] || [ "$tag" = latest ]; then
    record WARN "4 image tag pinned" "$image uses an unpinned tag (latest)"
  else
    record PASS "4 image tag pinned" "$image"
  fi
}

check_privileged() {
  local privileged
  privileged=$(docker inspect -f '{{.HostConfig.Privileged}}' "$TARGET")
  if [ "$privileged" = true ]; then
    record FAIL "5 privileged mode" "HostConfig.Privileged is true"
  else
    record PASS "5 privileged mode" "HostConfig.Privileged is false"
  fi
}

check_ports() {
  local count ports
  count=$(docker image inspect -f '{{len .Config.ExposedPorts}}' "$(docker inspect -f '{{.Image}}' "$TARGET")")
  ports=$(docker inspect -f '{{range $p, $_ := .Config.ExposedPorts}}{{$p}} {{end}}' "$TARGET")
  if [ "$count" -gt 2 ]; then
    record WARN "6 exposed ports" "$count ports exposed: $ports"
  else
    record PASS "6 exposed ports" "$count port(s) exposed: ${ports:-none}"
  fi
}

if [ -z "$TARGET" ]; then
  echo "usage: bash docker-audit.sh <container-name>" >&2
  exit 2
fi

mkdir -p "$REPORT_DIR"
STAMP=$(date +%Y%m%d-%H%M%S)
REPORT="$REPORT_DIR/audit-$TARGET-$STAMP.txt"

if check_exists; then
  check_root_user
  check_healthcheck
  check_image_tag
  check_privileged
  check_ports
fi

{
  echo "Docker hardening audit"
  echo "Auditor: $OWNER"
  echo "Container: $TARGET"
  echo "Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo
  printf '%s\n' "${LINES[@]}"
  echo
  echo "Summary: $PASS passed, $WARN warnings, $FAIL failures"
} | tee "$REPORT"

echo "Report: $REPORT"
[ "$FAIL" -eq 0 ]
