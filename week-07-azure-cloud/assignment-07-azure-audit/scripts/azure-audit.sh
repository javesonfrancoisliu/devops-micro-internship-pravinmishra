#!/bin/bash
set -u

full_name="Javeson Francois Liu"
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
report_dir="$base_dir/reports"
report_file="${AUDIT_REPORT_FILE:-$report_dir/azure-audit-report.txt}"
admin_ports="22 3389"

checks=(
check_nsg_admin_ports_open
check_storage_public_blob_access
check_vm_disk_encryption
check_mysql_public_network_access
)

pass_count=0
warning_count=0
failure_count=0
mkdir -p "$report_dir"
: > "$report_file"

write_line() {
echo "$1" | tee -a "$report_file"
}

mark_pass() {
write_line "[PASS] $1"
pass_count=$((pass_count + 1))
}

mark_warning() {
write_line "[WARN] $1"
warning_count=$((warning_count + 1))
}

mark_failure() {
write_line "[FAIL] $1"
failure_count=$((failure_count + 1))
}

print_header() {
write_line "========================================"
write_line "Azure Security Posture Audit Report"
write_line "========================================"
write_line "Full Name: $full_name"
write_line "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
write_line "Account: $(az account show --query name --output tsv 2>/dev/null || echo "not signed in")"
write_line ""
}

check_nsg_admin_ports_open() {
local port
local raw_rules
local open_rules
local ports_failed=0
for port in $admin_ports
do
if ! raw_rules=$(az network nsg list \
--query "[].securityRules[?direction=='Inbound' && access=='Allow' && contains(['*','0.0.0.0/0','Internet','Any'],sourceAddressPrefix) && contains(['$port','*'],destinationPortRange)].id" \
--output tsv 2>/dev/null)
then
mark_warning "Could not read NSG rules for port $port (az failed or not signed in)"
return
fi
open_rules=$(echo "$raw_rules" | sed 's#.*/networkSecurityGroups/##; s#/securityRules/#/#' | tr '\n' ' ')
if [ -n "${open_rules// /}" ]
then
mark_failure "NSG rule(s) allow port $port from 0.0.0.0/0: $open_rules"
ports_failed=1
fi
done
if [ "$ports_failed" -eq 0 ]
then
mark_pass "No NSG rule allows SSH (22) or RDP (3389) from 0.0.0.0/0"
fi
}

check_storage_public_blob_access() {
local name
local group
local blob_public
local accounts
local found=0
accounts=$(az storage account list --query "[].[name,resourceGroup]" --output tsv 2>/dev/null)
while IFS=$'\t' read -r name group
do
[ -z "$name" ] && continue
found=1
blob_public=$(az storage account show --name "$name" --resource-group "$group" --query allowBlobPublicAccess --output tsv 2>/dev/null || echo "unknown")
if [ "$blob_public" = "false" ]
then
mark_pass "Storage account '$name' has public blob access disabled"
elif [ "$blob_public" = "true" ]
then
mark_failure "Storage account '$name' allows public blob access (allowBlobPublicAccess=true)"
else
mark_warning "Storage account '$name' public blob access is '$blob_public' (not explicitly disabled)"
fi
done <<< "$accounts"
if [ "$found" -eq 0 ]
then
mark_warning "No storage account found or the account could not be read"
fi
}

check_vm_disk_encryption() {
local vm
local group
local disk
local encryption
local vms
local disk_names
local found=0
vms=$(az vm list --query "[].[name,resourceGroup]" --output tsv 2>/dev/null)
while IFS=$'\t' read -r vm group
do
[ -z "$vm" ] && continue
disk_names=$(az vm show --name "$vm" --resource-group "$group" --query "[storageProfile.osDisk.name, storageProfile.dataDisks[].name][]" --output tsv 2>/dev/null)
for disk in $disk_names
do
found=1
encryption=$(az disk show --name "$disk" --resource-group "$group" --query encryption.type --output tsv 2>/dev/null || echo "")
case "$encryption" in
EncryptionAtRest*)
mark_pass "VM '$vm' disk '$disk' is encrypted at rest ($encryption)"
;;
*)
mark_warning "VM '$vm' disk '$disk' encryption type is '${encryption:-unknown}'"
;;
esac
done
done <<< "$vms"
if [ "$found" -eq 0 ]
then
mark_warning "No VM disk found or the disks could not be read"
fi
}

check_mysql_public_network_access() {
local name
local access
local servers
local found=0
servers=$(az mysql flexible-server list --query "[].[name,network.publicNetworkAccess]" --output tsv 2>/dev/null)
while IFS=$'\t' read -r name access
do
[ -z "$name" ] && continue
found=1
if [ "$access" = "Disabled" ]
then
mark_pass "MySQL server '$name' has public network access disabled"
elif [ "$access" = "Enabled" ]
then
mark_failure "MySQL server '$name' has public network access enabled"
else
mark_warning "MySQL server '$name' public network access is '${access:-unknown}'"
fi
done <<< "$servers"
if [ "$found" -eq 0 ]
then
mark_warning "No MySQL flexible server found or the servers could not be read"
fi
}

print_summary() {
local overall_status
local script_exit_code

if [ "$failure_count" -gt 0 ]
then
overall_status="FAIL"
script_exit_code=2
elif [ "$warning_count" -gt 0 ]
then
overall_status="WARN"
script_exit_code=1
else
overall_status="HEALTHY"
script_exit_code=0
fi

write_line ""
write_line "Summary:"
write_line "PASS: $pass_count"
write_line "WARN: $warning_count"
write_line "FAIL: $failure_count"
write_line "Overall Status: $overall_status"
write_line "Script Exit Code: $script_exit_code"
return "$script_exit_code"
}

print_header
for check_function in "${checks[@]}"
do
"$check_function"
done
print_summary
exit $?
