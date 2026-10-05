# Deep Dive Lab: Working as an Agentic Platform Engineer

A hands-on companion repo for the meshcloud **Deep Dive Lab** — a relaxed, one-hour session where
we build one real thing step by step, with space to try it out and ask questions as we go.

**Goal:** take away how a platform engineer actually works with a coding agent — stand up a STACKIT
foundation from the hub, then extend it with your own building block and drive it live against
meshStack, the way the engineering behind [meshStack hub](https://hub.meshcloud.io) does.

Two chapters you do yourself (set up the foundation, then paste one prompt); after that **the agent
does the work** and you watch, guide, and review.

| Chapter | Who drives | What happens | Credentials |
|---|---|---|---|
| [00 — Foundation](00-foundation/) | you, once | add the `stackit-landingzone` reference architecture to your meshStack (one click from the [hub](https://hub.meshcloud.io/reference-architectures/stackit-landingzone), or local `tofu apply`) | meshStack admin · STACKIT org |
| [01 — Orientation](01-orientation/) | you read | the hub's own instruction files — the agent's real interface | none |
| [02 — Scaffold](02-scaffold/) | you prompt | one prompt; the agent builds a STACKIT VM building block from a base module | none |
| [03 — Definition](03-definition/) | agent | registers the module as a building block definition from pushed source | meshStack |
| [04 — Order & verify](04-order-and-verify/) | agent | orders a VM, reads the run logs, SSHs in — you watch the fix-forward loop | meshStack |
| [05 — Ship](05-ship/) | agent → you | runs the scorecard and opens the PR; you review | GitHub |

## The one idea, up front

An agent is effective here because **the platform's own instruction files are its interface.** You
don't teach it meshStack conventions every session — the hub repo already carries them, routed from
a single `CLAUDE.md`:

```
            CLAUDE.md  (the router: concepts + which file applies to which path)
                 │
     ┌───────────┼───────────────────────────────┬──────────────────────┐
  skills/module   references/module-layout   references/meshstack-     references/
  (the workflow)  (where files live)         integration (the BBD)     terraform-conventions …
```

Curate those once, and "add a building block that does X" becomes a reviewable diff instead of a
from-scratch explanation. Your job in the loop is the part a model can't own: standing up the
foundation, supplying the identity, reading a failed run, and deciding when it's actually done.

> The build happens in the real [meshstack-hub](https://github.com/meshcloud/meshstack-hub) repo.
> This repo is the **runbook**: the prompt, the context, a helper script, and a finished
> [`solution/`](solution/) to compare against.

## Prerequisites

You run the whole lab against **your own** meshStack — nothing here depends on a shared demo.

- **A meshStack workspace** you can deploy platform integrations and building block definitions in.
- **A STACKIT organization** the foundation can create projects and service accounts under.
- **OpenTofu ≥ 1.12** (`brew install opentofu`), the **meshStack CLI**, and **`jq`**. `nix develop`
  provides OpenTofu, jq, gh and Python if you use Nix.

Chapter 00 turns those into a working STACKIT foundation (a project + a federated `editor` service
account). Chapters 01–02 need nothing at all — you can follow them on a plane.

```bash
cp bin/env.sh.example bin/env.sh   # point it at your meshStack, then:
source bin/env.sh
cp demo.tfvars.example demo.tfvars # fill in from chapter 00's outputs
```

## What this repo is not

Not a module registry, and not where the building block lives — that is `meshstack-hub`. Not a
substitute for reading the hub's instruction files; it points you at them. And not an autopilot:
every chapter has a step only you can do.
