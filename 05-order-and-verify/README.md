# Chapter 05 — Order the VM and verify it

**Time: ~5 min. Credentials: meshStack.**

The definition exists and the service account trusts it. Order a VM and prove it works — all the way
to an SSH session, because "the run went green" and "I can log in" are different claims.

## Order it

The CLI has no create verb, so order through the API (it's authenticated by your profile):

```bash
meshstack api -X POST /api/meshobjects/meshbuildingblocks --request-json vm.json
```

`vm.json` targets your tenant and passes the module's inputs — `STACKIT_SERVICE_ACCOUNT_EMAIL`
(your `editor` SA), `name`, `machine_type` (`g1a.1d` exists in `eu01`), `enable_public_ip` = true,
an `ssh_allowed_cidr`, and empty `ssh_public_key` / `cloud_init`. See `bin/order-bb.sh` for the
exact payload.

## Watch the run

```bash
meshstack buildingblock list -o json                 # status + latestRunUuid
meshstack buildingblockrun logs <run-uuid>           # step-by-step logs on failure
```

If it fails, read the logs and fix forward — that loop (read the real error, change one thing,
re-run) is the job. Re-run after a code change with `meshstack buildingblock trigger-run <uuid>`
(after pushing the branch — chapter 03's rule still applies).

## Prove it

Read the outputs and log in:

```bash
meshstack buildingblock list -o json | jq -r '.[] | select(.metadata.uuid=="<vm-uuid>") | .status.outputs.public_ip.value'
# write the ssh_private_key output to a file, chmod 600, then:
ssh ubuntu@<public_ip>
```

A generated private key surfaces in the clear because meshStack has no sensitive outputs — the
module unwraps it with `nonsensitive()` on purpose (see
[`solution/stackit-server/buildingblock/outputs.tf`](../solution/stackit-server/buildingblock/outputs.tf)).
Treat it as a first-login convenience and rotate it. On to [chapter 06](../06-ship/).
