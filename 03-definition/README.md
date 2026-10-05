# Chapter 03 — The agent registers the definition

**What you do: watch. The agent does the work.**

Having scaffolded the module, the agent turns it into a **building block definition (BBD)** on your
meshStack — it applies the
[`meshstack_integration.tf`](https://github.com/meshcloud/meshstack-hub/blob/main/modules/stackit/server/meshstack_integration.tf)
it wrote, authenticating from your CLI profile. You don't run anything here; you watch for one thing.

## The one thing to watch

The definition does **not** contain the code. It contains **coordinates to the code**:

```hcl
implementation = { terraform = {
  repository_url  = "https://github.com/meshcloud/meshstack-hub.git"
  repository_path = "modules/stackit/server/buildingblock"
  ref_name        = var.hub.git_ref      # ← a branch that must be pushed
}}
```

So the agent has to **push the branch** before the definition is worth anything — the runner clones
`buildingblock/` from GitHub at that ref, not from the working tree. A good agent pushes first; if it
forgets, the next chapter's run fails identically every time until it does. This is the same
push-first discipline the
[integration conventions](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/meshstack-integration.md)
describe — and the single most common way a first run stalls.

When the agent is done you'll see a BBD uuid and a version uuid; those identify what the next chapter
orders. On to [chapter 04](../04-order-and-verify/).
