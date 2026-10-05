# Chapter 01 — Orientation: the files the agent actually reads

**Time: ~10 min. Credentials: none.**

Before building anything, see *how* the agent will know what to build. It does not know meshStack
conventions from training — it learns them from the hub repo's own instruction files, routed from a
single `CLAUDE.md`. This chapter is just reading; it's the mental model the rest of the lab relies on.

Open these in [meshstack-hub](https://github.com/meshcloud/meshstack-hub), in this order. Each line
says why it matters — that's exactly the judgement the agent applies when it decides what to load.

**The router**
- [`CLAUDE.md`](https://github.com/meshcloud/meshstack-hub/blob/main/CLAUDE.md) — domain concepts
  (building block *definition* vs *building block* vs *backplane* vs *hub module*) and a table
  mapping each path you might touch to the instruction file that governs it. Everything else is
  reached from here.

**The workflow and the layout**
- [`.agents/skills/module/SKILL.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/skills/module/SKILL.md) — the create-a-module workflow, step by step.
- [`.agents/references/module-layout.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/module-layout.md) — the two-tier `backplane/` + `buildingblock/` layout, the `README.md` front-matter, the logo, and the checklist a new module must satisfy.

**The meshStack wiring**
- [`.agents/references/meshstack-integration.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/meshstack-integration.md) — how `meshstack_integration.tf` declares the definition: the shared `variable "hub"` / `variable "meshstack"`, pinning sources and `ref_name` to `var.hub.git_ref`, `terraform_version`, the overridable `bbd_*` catalog fields, the `building_block_definition` output — and the **"Runner identity"** section, which is the WIF story chapter 04 makes concrete.
- [`.agents/references/stackit-backplane.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/stackit-backplane.md) — the STACKIT identity model (`STACKIT_SERVICE_ACCOUNT_EMAIL`, `STACKIT_USE_OIDC`, `STACKIT_FEDERATED_TOKEN_FILE`).
- [`.agents/references/bbd-readme.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/bbd-readme.md) — the readme an application team reads before ordering.

**The coding rules**
- [`.agents/references/terraform-conventions.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/terraform-conventions.md) — OpenTofu-only, `lifecycle.enabled` over `count = … ? 1 : 0`, provider versions floating inside one major, a comment on every `try`.

**The code to copy from**
- [`modules/stackit/git-runner/`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/git-runner) — the base we build the VM from: a STACKIT server with its network, security group, NIC and cloud-init, no backplane, service-account-as-input.
- [`modules/stackit/service-account/`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account) and [`service-account-federation/`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account-federation) — how an `editor` service account and its per-definition federation are created (chapter 04).

## The takeaway

The agent is good here for the same reason a new teammate would be: the repo tells it how it works.
The platform engineer's job is to keep those files true — so that "add a building block that does X"
lands as a reviewable diff, not a lecture. Notice in [chapter 02](../02-scaffold/) how short the
prompt is, and how much of the real instruction lives in the files above rather than the prompt.
