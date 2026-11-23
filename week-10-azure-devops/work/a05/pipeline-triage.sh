#!/usr/bin/env bash
set -u
set -o pipefail
umask 077

full_name="Javeson Francois Liu"
work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="${work_dir}/reports"
fixture_dir="${work_dir}/fixtures"

org="${AZDO_ORG:-https://dev.azure.com/javeson-dmi}"
project="${AZDO_PROJECT:-dmi-week10}"
pipelines="${AZDO_PIPELINES:-infra-epicbook theepicbook}"
agent_pool="${AZDO_AGENT_POOL:-self-hosted-linux}"
queue_limit_minutes="${QUEUE_LIMIT_MINUTES:-10}"
github_repo="${GH_REPO:-}"

agent_pattern='no agent found in pool|no hosted parallelism|agent is offline|did not connect within the alloted time|waiting for an agent|no online agents|job was not acquired|lost communication with the server|agent request is not running'
auth_pattern='permission denied \(publickey|authentication failed|AADSTS[0-9]+|AuthorizationFailed|unauthorized|HTTP 40[13]|status code 40[13]|has not been authorized|service connection .*(not found|not authorized)|invalid client secret|bad credentials|access denied|login failed|TF400813|TF401019'
dependency_pattern='npm ERR! (code )?(E404|ERESOLVE|ETARGET|ENOTFOUND)|npm error (code )?(E404|ERESOLVE|ETARGET)|404 Not Found - GET https://registry|No matching version found|Could not resolve dependency|Unable to locate package|has no installation candidate|Could not find a version that satisfies|No matching distribution|ModuleNotFoundError|Cannot find module|Failed to download|No package matching .* is available|Failed to install packages'
test_pattern='Tests: +[0-9]+ failed|Test Suites: +[0-9]+ failed|^FAIL |AssertionError|● .* ›|[0-9]+ failing|FAILED \(failures='
build_pattern='Failed to compile|error TS[0-9]+|SyntaxError|Module not found: Error|Build failed|Unsupported argument|Missing required argument|Invalid reference|Syntax Error while loading YAML|ERROR! Syntax Error|fatal: \[.*FAILED!|failed=[1-9]|unreachable=[1-9]|configuration file .* test failed|Process completed with exit code [1-9]'

category_names="agent authentication dependency test build"

usage() {
  cat <<'USAGE'
pipeline-triage.sh: read-only triage of the latest Azure DevOps and GitHub Actions run

Usage:
  ./pipeline-triage.sh                  triage the latest run of every configured pipeline
  ./pipeline-triage.sh <pipeline-name>  triage one Azure DevOps pipeline
  ./pipeline-triage.sh --log-file FILE  classify a saved log file, no network
  ./pipeline-triage.sh --self-test      classify the bundled fixtures and audit this script
  ./pipeline-triage.sh --help           show this text

Environment (all optional):
  AZDO_ORG, AZDO_PROJECT, AZDO_PIPELINES, AZDO_AGENT_POOL, QUEUE_LIMIT_MINUTES, GH_REPO

Exit codes: 0 healthy, 1 error, 2 failure classified, 3 run not finished yet
The script only reads run status and logs. It never starts, retries, cancels or approves a run.
USAGE
}

redact() {
  sed -E \
    -e 's#(://)[^/@ ]+:[^/@ ]+@#\1[REDACTED]@#g' \
    -e 's/("(password|passwd|pwd|secret|token|accesstoken|apikey|api_key|client_secret|pat)" *: *")[^"]*/\1[REDACTED]/Ig' \
    -e 's/(password|passwd|pwd|secret|token|apikey|api_key|client_secret|pat)([=:] *)[^ ]+/\1\2[REDACTED]/Ig' \
    -e 's/[A-Za-z0-9]{70,}/[REDACTED]/g' \
    -e 's/(Authorization:) +((Bearer|Basic) +)?[^ ]+/\1 [REDACTED]/Ig' \
    -e 's/(Bearer|Basic) +[A-Za-z0-9._=+\/-]+/\1 [REDACTED]/Ig' \
    -e 's/[a-z2-7]{52}/[REDACTED]/g' \
    -e 's/-----BEGIN [A-Z ]*PRIVATE KEY-----.*/[REDACTED PRIVATE KEY]/'
}

pattern_for() {
  case "$1" in
    agent) printf '%s' "${agent_pattern}" ;;
    authentication) printf '%s' "${auth_pattern}" ;;
    dependency) printf '%s' "${dependency_pattern}" ;;
    test) printf '%s' "${test_pattern}" ;;
    build) printf '%s' "${build_pattern}" ;;
  esac
}

check_agent() {
  grep -n -i -E -m 5 -- "${agent_pattern}" "$1"
}

check_authentication() {
  grep -n -i -E -m 5 -- "${auth_pattern}" "$1"
}

check_dependency() {
  grep -n -i -E -m 5 -- "${dependency_pattern}" "$1"
}

check_test() {
  grep -n -E -m 5 -- "${test_pattern}" "$1"
}

check_build() {
  grep -n -i -E -m 5 -- "${build_pattern}" "$1"
}

classify_file() {
  local file="$1" name evidence
  for name in ${category_names}; do
    evidence="$("check_${name}" "${file}" | redact)"
    if [ -n "${evidence}" ]; then
      printf '%s\n%s\n' "${name}" "${evidence}"
      return 0
    fi
  done
  return 1
}

recommendation_for() {
  case "$1" in
    agent) printf '%s' "Check that the agent service is running on the VM and shows Online under Project settings, Agent pools. Start the service yourself, then re-run the pipeline yourself." ;;
    authentication) printf '%s' "Open the service connection or Secure File named in the evidence and confirm it is valid and authorized for this pipeline. Renew the credential yourself, then re-run." ;;
    dependency) printf '%s' "Fix the package name or version in package.json, requirements or the apt package list quoted in the evidence, push the fix, and let the trigger run." ;;
    test) printf '%s' "Open the failing test quoted in the evidence. Decide whether the test or the code is wrong, fix that one, push, and let the trigger run." ;;
    build) printf '%s' "Open the file and line quoted in the evidence, correct the syntax or configuration error, push, and let the trigger run." ;;
    *) printf '%s' "No known pattern matched. Read the full log around the first error line and report it." ;;
  esac
}

write_report_header() {
  local report="$1" title="$2"
  {
    printf 'PIPELINE TRIAGE REPORT (read-only)\n'
    printf 'Prepared for: %s\n' "${full_name}"
    printf 'Generated   : %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    printf 'Subject     : %s\n' "${title}"
    printf -- '----------------------------------------\n'
  } >"${report}"
}

emit() {
  local report="$1"
  shift
  printf '%s\n' "$*" | tee -a "${report}"
}

emit_verdict() {
  local report="$1" result="$2" category="$3" evidence="$4"
  emit "${report}" "RESULT: ${result}"
  emit "${report}" "CATEGORY: ${category}"
  if [ -n "${evidence}" ]; then
    emit "${report}" "EVIDENCE:"
    printf '%s\n' "${evidence}" | sed 's/^/  > /' | tee -a "${report}"
  fi
  if [ "${result}" = "FAILURE" ]; then
    emit "${report}" "RECOMMENDED FIX: $(recommendation_for "${category}")"
    emit "${report}" "ACTION TAKEN BY THIS SCRIPT: none (read-only)"
  fi
}

agent_status_text() {
  local pool_id
  pool_id="$(az pipelines pool list --org "${org}" --pool-name "${agent_pool}" --query "[0].id" -o tsv 2>/dev/null)"
  if [ -z "${pool_id}" ]; then
    printf 'Agent pool %s could not be read\n' "${agent_pool}"
    return 0
  fi
  az pipelines agent list --org "${org}" --pool-id "${pool_id}" --query "[].[name,status,enabled]" -o tsv 2>/dev/null |
    while IFS=$'\t' read -r name status enabled; do
      printf 'agent %s status=%s enabled=%s\n' "${name}" "${status}" "${enabled}"
    done
}

minutes_since() {
  local stamp="$1" cleaned epoch now
  cleaned="${stamp%%.*}"
  cleaned="${cleaned%Z}"
  epoch="$(date -u -j -f '%Y-%m-%dT%H:%M:%S' "${cleaned}" '+%s' 2>/dev/null || date -u -d "${cleaned}" '+%s' 2>/dev/null)"
  now="$(date -u '+%s')"
  if [ -z "${epoch}" ]; then
    printf '0'
    return 0
  fi
  printf '%s' $(((now - epoch) / 60))
}

collect_azure_log() {
  local run_id="$1" out="$2" timeline failed_logs log_id log_name tmp
  : >"${out}"
  timeline="$(mktemp)"
  az devops invoke --org "${org}" --area build --resource timeline \
    --route-parameters project="${project}" buildId="${run_id}" \
    --api-version 7.1 -o json >"${timeline}" 2>>"${out}"
  az devops invoke --org "${org}" --area build --resource timeline \
    --route-parameters project="${project}" buildId="${run_id}" \
    --api-version 7.1 --query "records[].issues[].message" -o tsv 2>/dev/null >>"${out}"
  failed_logs="$(jq -r '.records[]? | select(.result == "failed" and .log != null) | "\(.log.id)\t\(.name)"' "${timeline}" 2>/dev/null)"
  while IFS=$'\t' read -r log_id log_name; do
    [ -n "${log_id}" ] || continue
    tmp="$(mktemp)"
    az devops invoke --org "${org}" --area build --resource logs \
      --route-parameters project="${project}" buildId="${run_id}" logId="${log_id}" \
      --accept-media-type text/plain --api-version 7.1 --out-file "${tmp}" >/dev/null 2>&1
    printf '===== failed step: %s (log %s) =====\n' "${log_name}" "${log_id}" >>"${out}"
    tail -n 200 "${tmp}" >>"${out}"
    rm -f "${tmp}"
  done <<<"${failed_logs}"
  rm -f "${timeline}"
}

triage_azure_pipeline() {
  local name="$1" stamp report row run_id status result queued branch commit log_file verdict category evidence waited
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
  report="${report_dir}/triage-azure-${name}-${stamp}.txt"
  mkdir -p "${report_dir}"
  write_report_header "${report}" "Azure DevOps pipeline ${name} in ${org}/${project}"

  row="$(az pipelines runs list --org "${org}" --project "${project}" --top 1 --query-order QueueTimeDesc \
    --query "[?definition.name=='${name}'] | [0].[id,status,result,queueTime,sourceBranch,sourceVersion]" -o tsv 2>&1)"
  if [ "$?" -ne 0 ] || [ -z "${row}" ] || [ "${row}" = "None" ]; then
    verdict="$(printf '%s' "${row}" | redact)"
    if printf '%s' "${verdict}" | grep -q -i -E -- "${auth_pattern}|not logged|az devops login|PAT"; then
      emit_verdict "${report}" "FAILURE" "authentication" "$(printf '%s' "${verdict}" | head -n 3)"
      emit "${report}" "REPORT: ${report}"
      return 2
    fi
    emit "${report}" "RESULT: ERROR"
    emit "${report}" "No run found or the query failed: $(printf '%s' "${verdict}" | head -n 3)"
    emit "${report}" "REPORT: ${report}"
    return 1
  fi

  IFS=$'\t' read -r run_id status result queued branch commit <<<"${row}"
  emit "${report}" "Run id      : ${run_id}"
  emit "${report}" "Status      : ${status}"
  emit "${report}" "Result      : ${result}"
  emit "${report}" "Queued      : ${queued}"
  emit "${report}" "Branch      : ${branch}"
  emit "${report}" "Commit      : ${commit}"
  emit "${report}" "Agents      :"
  agent_status_text | sed 's/^/  /' | tee -a "${report}"

  if [ "${status}" = "notStarted" ] || [ "${status}" = "postponed" ]; then
    waited="$(minutes_since "${queued}")"
    emit "${report}" "Queued for ${waited} minutes (limit ${queue_limit_minutes})"
    if [ "${waited}" -ge "${queue_limit_minutes}" ]; then
      emit_verdict "${report}" "FAILURE" "agent" "Run ${run_id} has been ${status} for ${waited} minutes; see the agent list above"
      emit "${report}" "REPORT: ${report}"
      return 2
    fi
    emit "${report}" "RESULT: PENDING"
    emit "${report}" "REPORT: ${report}"
    return 3
  fi

  if [ "${status}" != "completed" ]; then
    emit "${report}" "RESULT: PENDING"
    emit "${report}" "The run is still ${status}; triage it again after it finishes."
    emit "${report}" "REPORT: ${report}"
    return 3
  fi

  if [ "${result}" = "succeeded" ]; then
    emit_verdict "${report}" "HEALTHY" "none" ""
    emit "${report}" "REPORT: ${report}"
    return 0
  fi

  log_file="$(mktemp)"
  collect_azure_log "${run_id}" "${log_file}"
  if verdict="$(classify_file "${log_file}")"; then
    category="$(printf '%s\n' "${verdict}" | head -n 1)"
    evidence="$(printf '%s\n' "${verdict}" | tail -n +2)"
  else
    category="unclassified"
    evidence="$(grep -n -i -E -m 5 'error|failed' "${log_file}" | redact)"
  fi
  rm -f "${log_file}"
  emit_verdict "${report}" "FAILURE" "${category}" "${evidence}"
  emit "${report}" "REPORT: ${report}"
  return 2
}

triage_github_repo() {
  local repo="$1" stamp report row run_id status conclusion workflow log_file verdict category evidence
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
  report="${report_dir}/triage-github-${repo//\//-}-${stamp}.txt"
  mkdir -p "${report_dir}"
  write_report_header "${report}" "GitHub Actions in ${repo}"

  row="$(gh run list --repo "${repo}" --limit 1 --json databaseId,status,conclusion,workflowName \
    --jq '.[0] | [.databaseId, .status, .conclusion, .workflowName] | @tsv' 2>&1)"
  if [ "$?" -ne 0 ] || [ -z "${row}" ]; then
    emit "${report}" "RESULT: ERROR"
    emit "${report}" "No run found or the query failed: $(printf '%s' "${row}" | redact | head -n 3)"
    emit "${report}" "REPORT: ${report}"
    return 1
  fi
  IFS=$'\t' read -r run_id status conclusion workflow <<<"${row}"
  emit "${report}" "Run id      : ${run_id}"
  emit "${report}" "Workflow    : ${workflow}"
  emit "${report}" "Status      : ${status}"
  emit "${report}" "Conclusion  : ${conclusion}"

  if [ "${status}" != "completed" ]; then
    emit "${report}" "RESULT: PENDING"
    emit "${report}" "REPORT: ${report}"
    return 3
  fi
  if [ "${conclusion}" = "success" ]; then
    emit_verdict "${report}" "HEALTHY" "none" ""
    emit "${report}" "REPORT: ${report}"
    return 0
  fi

  log_file="$(mktemp)"
  gh run view "${run_id}" --repo "${repo}" --log-failed >"${log_file}" 2>&1
  if verdict="$(classify_file "${log_file}")"; then
    category="$(printf '%s\n' "${verdict}" | head -n 1)"
    evidence="$(printf '%s\n' "${verdict}" | tail -n +2)"
  else
    category="unclassified"
    evidence="$(grep -n -i -E -m 5 'error|failed' "${log_file}" | redact)"
  fi
  rm -f "${log_file}"
  emit_verdict "${report}" "FAILURE" "${category}" "${evidence}"
  emit "${report}" "REPORT: ${report}"
  return 2
}

triage_log_file() {
  local file="$1" stamp report verdict category evidence
  [ -r "${file}" ] || { printf 'Cannot read %s\n' "${file}" >&2; return 1; }
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')-$$"
  report="${report_dir}/triage-file-${stamp}.txt"
  mkdir -p "${report_dir}"
  write_report_header "${report}" "Saved log ${file}"
  if verdict="$(classify_file "${file}")"; then
    category="$(printf '%s\n' "${verdict}" | head -n 1)"
    evidence="$(printf '%s\n' "${verdict}" | tail -n +2)"
    emit_verdict "${report}" "FAILURE" "${category}" "${evidence}"
    emit "${report}" "REPORT: ${report}"
    return 2
  fi
  emit_verdict "${report}" "HEALTHY" "none" ""
  emit "${report}" "REPORT: ${report}"
  return 0
}

audit_script_is_read_only() {
  local forbidden_a forbidden_b forbidden_c forbidden_d hits
  forbidden_a="az pipelines ru""n "
  forbidden_b="gh run re""run|gh run can""cel|gh run de""lete|gh workflow ru""n"
  forbidden_c="http-method +(PO""ST|PU""T|PAT""CH|DEL""ETE)"
  forbidden_d="builds/.*/can""cel|az pipelines build que""ue"
  hits="$(grep -n -E -- "${forbidden_a}|${forbidden_b}|${forbidden_c}|${forbidden_d}" "${BASH_SOURCE[0]}" | grep -v -E 'forbidden_[a-d]=' || true)"
  if [ -n "${hits}" ]; then
    printf 'AUDIT FAIL: write-capable command found\n%s\n' "${hits}"
    return 1
  fi
  printf 'AUDIT PASS: no command that starts, retries, cancels or approves a run\n'
  return 0
}

self_test() {
  local file expected got failures=0 verdict
  mkdir -p "${report_dir}"
  for file in "${fixture_dir}"/*.log; do
    expected="$(basename "${file}" .log)"
    expected="${expected%%-*}"
    if verdict="$(classify_file "${file}")"; then
      got="$(printf '%s\n' "${verdict}" | head -n 1)"
    else
      got="healthy"
    fi
    if [ "${got}" = "${expected}" ]; then
      printf 'PASS  %-34s expected=%-15s got=%s\n' "$(basename "${file}")" "${expected}" "${got}"
    else
      printf 'FAIL  %-34s expected=%-15s got=%s\n' "$(basename "${file}")" "${expected}" "${got}"
      failures=$((failures + 1))
    fi
  done
  audit_script_is_read_only || failures=$((failures + 1))
  [ "${failures}" -eq 0 ]
}

require_tools() {
  local tool
  for tool in az jq; do
    command -v "${tool}" >/dev/null 2>&1 || { printf 'Missing tool: %s\n' "${tool}" >&2; return 1; }
  done
  az extension show --name azure-devops >/dev/null 2>&1 || { printf 'Missing az extension: azure-devops\n' >&2; return 1; }
}

main() {
  local worst=0 code name
  case "${1:-}" in
    --help|-h) usage; return 0 ;;
    --self-test) self_test; return $? ;;
    --log-file) triage_log_file "${2:-}"; return $? ;;
  esac

  require_tools || return 1
  printf 'Pipeline triage for %s (read-only)\n' "${full_name}"

  if [ -n "${1:-}" ]; then
    triage_azure_pipeline "$1"
    return $?
  fi

  for name in ${pipelines}; do
    triage_azure_pipeline "${name}"
    code=$?
    [ "${code}" -gt "${worst}" ] && worst="${code}"
  done
  if [ -n "${github_repo}" ] && command -v gh >/dev/null 2>&1; then
    triage_github_repo "${github_repo}"
    code=$?
    [ "${code}" -gt "${worst}" ] && worst="${code}"
  fi
  return "${worst}"
}

main "$@"
