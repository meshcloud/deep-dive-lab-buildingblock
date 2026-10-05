# Deep Dive Lab: Working as an Agentic Platform Engineer

A hands-on companion repo for the meshcloud **Deep Dive Lab** — a relaxed, one-hour session where
we build one real thing step by step, with space to try it out and ask questions as we go.

**Goal:** take away how a platform engineer actually works with a coding agent — stand up a STACKIT
foundation from the hub, then extend it with your own building block and drive it live against
meshStack, the way the engineering behind [meshStack hub](https://hub.meshcloud.io) does.

Each directory is one chapter. Do [00](00-foundation/) once to get a foundation, then follow the
rest in order.

| Chapter | What you do | Credentials | Runtime |
|---|---|---|---|
| [00 — Foundation](00-foundation/) | deploy the `stackit-landingzone` reference architecture into your meshStack | meshStack admin · STACKIT org | ~15 min, once |
| [01 — Orientation](01-orientation/) | read the hub's own instruction files — the agent's real interface | none | read-only |
| [02 — Scaffold](02-scaffold/) | paste one prompt; the agent builds a STACKIT VM building block from a base module | none | ~3 min |
| [03 — Definition](03-definition/) | turn the module into a building block definition on meshStack, from source | meshStack | ~1 min |
| [04 — Identity](04-identity/) | federate your foundation's service account to the new definition | meshStack · STACKIT | ~2 min |
| [05 — Order & verify](05-order-and-verify/) | order a VM, read the run logs, SSH into it | meshStack | ~3 min |
| [06 — Ship](06-ship/) | run the scorecard and open the PR | GitHub | ~2 min |

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
