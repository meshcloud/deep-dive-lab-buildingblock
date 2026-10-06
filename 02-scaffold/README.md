# Chapter 02 — Scaffold the building block, with an agent

**Time: ~10 min. Credentials: none.**

This is the heart of the lab. You hand the agent one short prompt and it produces a reviewable
module — because the conventions live in the hub's instruction files (chapter 01), not in your
prompt. Watch how little the prompt says and how much the agent reads.

## The prompt

Paste this into a fresh Claude Code session, run from a checkout of
[meshstack-hub](https://github.com/meshcloud/meshstack-hub):

> We built [`modules/stackit/git-runner`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/git-runner)
> before we knew the runner works natively in STACKIT, but it's a good base for a generic VM
> building block. Use it to build a STACKIT VM building block under `modules/stackit/server` (or
> reuse the one already there). I want an optional personal cloud-init file as an optional CODE
> input, and an SSH key generated so I can log into the VM after it's created.
>
> I'm already logged into my meshStack with the meshStack CLI, so use it directly — no API key, and
> no `provider "meshstack"` block anywhere. `meshstack api` both creates the building block
> definition and places the order (there is no CLI create verb); `meshstack buildingblock` and
> `meshstack buildingblockrun logs` read the runs.
>
> A STACKIT project and a service account with the `editor` role on it already exist — don't ask me
> for the ids, find them with the CLI: `meshstack buildingblock list` shows the project's STACKIT
> tenant and its existing **STACKIT Service Account** and **STACKIT Service Account Federation**
> building blocks, and the service account email is in their inputs. That *STACKIT Service Account Federation**
> building block federates the service account to building block definitions —
> so register your definition, add its uuid to its `federated_building_block_definitions` input,
> re-run it, and the VM run then authenticates as the service account via WIF.
>
> Create an extra branch, build the building block, add it as a definition, order a VM on that
> project, and test it — SSH in to prove it. When it works, open a PR.

## What good looks like

The agent should, without being told the mechanics:

- invoke the [`module`](https://github.com/meshcloud/meshstack-hub/tree/main/.claude/skills/module)
  skill and follow [`module-layout.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/module-layout.md) —
  a `buildingblock/` tier (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `provider.tf`,
  `README.md` with front-matter, `logo.png`) and a `meshstack_integration.tf`, no `backplane/`;
- model the optional cloud-init as a `CODE` input and generate an SSH key with `tls_private_key`,
  returning the private key as an output;
- follow [`terraform-conventions.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/terraform-conventions.md)
  (OpenTofu, `lifecycle.enabled`, floating provider versions, a comment on every `try`).

## Check it before trusting it

No meshStack needed yet — this is all local:

```bash
tofu -chdir=modules/stackit/server/buildingblock validate
node tools/scorecard/scorecard.mjs --module=stackit/server
```

Compare what the agent wrote against [`solution/stackit-server/`](../solution/stackit-server/) in
this repo. Differences are a conversation, not a failure — the point is that it's close enough to
*review*, which is the whole shift this lab is about. On to [chapter 03](../03-definition/).
