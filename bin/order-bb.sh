#!/usr/bin/env bash
# Hands-off driver for chapters 03–05: create the building block definition from a hub module,
# federate the service account to it, order a VM building block, and SSH in to prove it.
#
# This is the automation fallback. In the session you normally do these steps interactively with
# the agent; run this when you'd rather not, or to reset between takes.
#
# Prereqs (see 04-identity/): a logged-in CLI profile, a STACKIT tenant, a service account with the
# `editor` role on its project, and the Service Account Federation BBD version uuid from the
# marketplace. The branch must be pushed so the runner can fetch buildingblock/.
#
# Usage:
#   HUB=~/meshcloud/repos/meshstack-hub \
#   MODULE=stackit/server BRANCH=feature/stackit-server-vm \
#   WORKSPACE=deepdive PROFILE=deepdive \
#   TENANT_UUID=... SA_EMAIL=...@sa.stackit.cloud FEDERATION_VERSION=... \
#   MACHINE_TYPE=g1a.1d VM_NAME=demo-vm \
#   bin/order-bb.sh
set -euo pipefail

HUB="${HUB:-$HOME/meshcloud/repos/meshstack-hub}"
MODULE="${MODULE:-stackit/server}"
BRANCH="${BRANCH:?set BRANCH to the pushed hub branch}"
WORKSPACE="${WORKSPACE:-deepdive}"
PROFILE="${PROFILE:-deepdive}"
TENANT_UUID="${TENANT_UUID:?set TENANT_UUID}"
SA_EMAIL="${SA_EMAIL:?set SA_EMAIL (editor on the project)}"
FEDERATION_VERSION="${FEDERATION_VERSION:?set FEDERATION_VERSION (Service Account Federation BBD version uuid)}"
MACHINE_TYPE="${MACHINE_TYPE:-g1a.1d}"
VM_NAME="${VM_NAME:-demo-vm}"
export MESHSTACK_PROFILE="$PROFILE"

say() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }

field() { # <bb-uuid> <python-expr over st> -> prints
  meshstack buildingblock list -o json | python3 -c "
import sys,json
b=[x for x in json.load(sys.stdin) if x.get('metadata',{}).get('uuid')=='$1'][0]
st=b.get('status',{}); print($2)"
}

poll() { # <bb-uuid> <label>
  local uuid="$1" label="$2" s
  for _ in $(seq 1 90); do
    s=$(field "$uuid" "st.get('status','')")
    printf '%s  %s = %s\n' "$(date +%H:%M:%S)" "$label" "$s"
    case "$s" in
      SUCCEEDED) return 0 ;;
      FAILED|REJECTED)
        say "$label FAILED — run logs:"
        meshstack buildingblockrun logs "$(field "$uuid" "st.get('latestRunUuid','')")" \
          | python3 -c "import sys,json;[print(x['status'],'|',x['displayName'],'\n',(x.get('userMessage') or '')) for x in json.load(sys.stdin)['steps'] if x['status']=='FAILED']"
        return 1 ;;
    esac
    sleep 15
  done
  return 1
}

order() { # <json-file> -> prints created bb uuid
  meshstack api -X POST /api/meshobjects/meshbuildingblocks --request-json "$1" \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['metadata']['uuid'])"
}

S="$(mktemp -d)"

say "1/5  create the building block definition from $MODULE @ $BRANCH"
cat > "$S/main.tf" <<EOF
terraform { required_providers { meshstack = { source = "meshcloud/meshstack", version = ">= 0.21.0" } } }
provider "meshstack" { profile = "$PROFILE" }
module "under_test" {
  source    = "$HUB/modules/$MODULE"
  meshstack = { owning_workspace_identifier = "$WORKSPACE", tags = {} }
  hub       = { git_ref = "$BRANCH", bbd_draft = true }
}
output "bbd_uuid"     { value = module.under_test.building_block_definition.uuid }
output "version_uuid" { value = module.under_test.building_block_definition.version_ref.uuid }
EOF
( cd "$S" && tofu init -upgrade >/dev/null && tofu apply -target=module.under_test -auto-approve >/dev/null )
BBD=$(cd "$S" && tofu output -raw bbd_uuid)
VERSION=$(cd "$S" && tofu output -raw version_uuid)
echo "BBD=$BBD  version=$VERSION"

say "2/5  federate $SA_EMAIL to the new definition (per-definition STACKIT WIF)"
cat > "$S/fed.json" <<EOF
{ "apiVersion":"v2-preview","kind":"meshBuildingBlock","spec":{
  "displayName":"$VM_NAME-federation",
  "buildingBlockDefinitionVersionRef":{"kind":"meshBuildingBlockDefinitionVersion","uuid":"$FEDERATION_VERSION"},
  "targetRef":{"kind":"meshTenant","uuid":"$TENANT_UUID"},
  "inputs":{
    "service_account_email":{"valueType":"STRING","value":"$SA_EMAIL"},
    "federated_building_block_definitions":{"valueType":"CODE","value":"[\"$BBD\"]"}
  }}}
EOF
FED=$(order "$S/fed.json"); echo "federation bb=$FED"; poll "$FED" "federation"

say "3/5  order the VM building block"
cat > "$S/vm.json" <<EOF
{ "apiVersion":"v2-preview","kind":"meshBuildingBlock","spec":{
  "displayName":"$VM_NAME",
  "buildingBlockDefinitionVersionRef":{"kind":"meshBuildingBlockDefinitionVersion","uuid":"$VERSION"},
  "targetRef":{"kind":"meshTenant","uuid":"$TENANT_UUID"},
  "inputs":{
    "STACKIT_SERVICE_ACCOUNT_EMAIL":{"valueType":"STRING","value":"$SA_EMAIL"},
    "name":{"valueType":"STRING","value":"$VM_NAME"},
    "machine_type":{"valueType":"STRING","value":"$MACHINE_TYPE"},
    "enable_public_ip":{"valueType":"BOOLEAN","value":true},
    "ssh_allowed_cidr":{"valueType":"STRING","value":"0.0.0.0/0"},
    "ssh_public_key":{"valueType":"STRING","value":""},
    "cloud_init":{"valueType":"CODE","value":""}
  }}}
EOF
VM=$(order "$S/vm.json"); echo "vm bb=$VM"; poll "$VM" "vm"

say "4/5  read outputs"
PUBIP=$(field "$VM" "st.get('outputs',{}).get('public_ip',{}).get('value','')")
echo "public_ip=$PUBIP"
KEY="$S/vm_key"
meshstack buildingblock list -o json | python3 -c "
import sys,json
b=[x for x in json.load(sys.stdin) if x.get('metadata',{}).get('uuid')=='$VM'][0]
v=b['status']['outputs']['ssh_private_key']['value']
while isinstance(v,str) and v.lstrip().startswith('\"'): v=json.loads(v)
open('$KEY','w').write(v if v.endswith('\n') else v+'\n')"
chmod 600 "$KEY"

say "5/5  ssh ubuntu@$PUBIP"
ssh -i "$KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=20 \
  ubuntu@"$PUBIP" 'echo CONNECTED as $(whoami) on $(hostname); cloud-init status || true'

echo; echo "Done. BBD=$BBD  VM=$VM  scratch=$S"
echo "Delete the building blocks in the meshPanel UI afterwards (the demo login cannot delete)."
