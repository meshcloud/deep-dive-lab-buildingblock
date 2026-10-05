# Chapter 03 — From module to building block definition

**Time: ~5 min. Credentials: meshStack.**

A module isn't a building block yet. The
[`meshstack_integration.tf`](https://github.com/meshcloud/meshstack-hub/blob/main/modules/stackit/server/meshstack_integration.tf)
the agent wrote *declares* a building block definition (BBD): its inputs, outputs, catalog entry, and
— crucially — **coordinates to the code**, not the code itself. This chapter applies it against your
meshStack so the definition exists in your workspace.

## Push first

The runner clones `buildingblock/` from GitHub at `var.hub.git_ref`. Your working tree does not
exist as far as it's concerned, so **commit and push the branch** before creating the definition —
an unpushed change runs nothing. This is the same discipline the
[integration conventions](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/meshstack-integration.md)
describe for pinning `ref_name` to a ref.

## Create the definition

`meshstack_integration.tf` is a root module. Point a tiny wrapper at it and apply — the provider
authenticates from your CLI profile, so there is no provider block to write:

```hcl
# scratch/main.tf
provider "meshstack" { profile = "<your-profile>" }
module "under_test" {
  source    = "../meshstack-hub/modules/stackit/server"
  meshstack = { owning_workspace_identifier = "<your-workspace>", tags = {} }
  hub       = { git_ref = "<your-branch>", bbd_draft = true }
}
output "bbd" { value = module.under_test.building_block_definition }
```

```bash
tofu -chdir=scratch init && tofu -chdir=scratch apply
```

The output's `uuid` and `version_ref.uuid` identify the definition and the version you'll order
against. (`bin/order-bb.sh` does exactly this, plus chapters 04–05, in one go.)

## The thing that catches everyone once

The definition contains **coordinates**, not your code:

```hcl
implementation = { terraform = {
  repository_url  = "https://github.com/meshcloud/meshstack-hub.git"
  repository_path = "modules/stackit/server/buildingblock"
  ref_name        = var.hub.git_ref      # ← the branch you pushed
}}
```

Edit `buildingblock/`, forget to push, re-run, watch it fail identically, lose twenty minutes. Push,
then re-run. On to [chapter 04](../04-identity/) — the definition exists, but nothing can act as a
service account on it yet.
