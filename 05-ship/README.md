# Chapter 05 — The agent ships it

**What you do: review, then let it open the PR.**

The VM built and the agent logged in. Now it makes the change mergeable the way a hub contribution
is — and this is where you stop watching and start reviewing.

## What the agent does

- runs the hub's maturity scorecard and fixes the **module** to satisfy it (never the check):
  `node tools/scorecard/scorecard.mjs --module=stackit/server` — Core, Integration **and** Testing green;
- adds an `e2e/` smoke test with the hub's
  [`e2e-test`](https://github.com/meshcloud/meshstack-hub/tree/main/.agents/skills/e2e-test) skill,
  then proves it by dispatching the hub's smoke-test workflow against the PR branch (see below);
- pushes the branch and opens the PR, with a body that states what was verified **live** (run
  SUCCEEDED, SSH worked, smoke test green) — the hub's CI is lint-only, so a real run is the only
  proof it works.

## The smoke test

### What it actually is

A hub smoke test is just **`tofu test` run in the module's `e2e/`** — but in a place that has a live
meshStack to run against. The hub's own CI never does this (it's lint-only), so it lives in a
separate private repo, [`meshstack-smoke-test`](https://github.com/meshcloud/meshstack-smoke-test),
which owns the throwaway **fixtures**: a scratch workspace, and a STACKIT project and tenant to
build into. On dispatch the runner:

1. resolves the hub commit to test (from `meshstack_hub_ref`) and checks it out;
2. renders one **`test_context`** var-file — `workspace`, a unique `run_id`, and
   `fixtures.stackit.{project_id, mesh_tenant_id}` — and hands it to the module. That single grab-bag
   is why the test code carries no environment specifics and no secrets;
3. runs `tofu test` in `e2e/`, which **applies → runs the assertions → destroys**. The VM is
   ephemeral: a green run means a real server actually came up, answered, and was torn down. Every
   resource is named from `run_id` so a leaked one is traceable to its run.

### How this module's `e2e/` is wired

One `main.tf` orders the building block; the rest is two interchangeable modes behind
`module.definition` (mirroring [`stackit/secrets-manager`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/secrets-manager/e2e)):

- **`modes/hub`** — builds the definition from *your pushed branch*, stands up the run's WIF identity
  (the same per-definition federation from chapter 04), and returns its version ref. This is the mode
  the dispatch below exercises.
- **`modes/foundation`** — builds nothing; it looks an already-published definition up by display
  name and orders against that, for a foundation repo smoke-testing what it deployed.

`tests/stackit_server.tftest.hcl` is mode-agnostic — it asserts the run SUCCEEDED and checks the
`public_ip`, `server_id`, `ssh_username`, `ssh_command` and `ssh_private_key` outputs, and passes a
personal cloud-init so the `user_data` path runs for real.

### Running it

You can't run it locally — it needs those fixtures and secrets. You dispatch it against the PR
branch; `meshstack_hub_ref` has to be a **pushed** ref, because the runner clones `buildingblock/`
from GitHub at the commit it resolves, not from your disk:

```bash
gh workflow run smoke-test.yml -R meshcloud/meshstack-smoke-test \
  -f module=stackit/server -f meshstack_hub_ref=refs/pull/<nr>/head
gh run watch -R meshcloud/meshstack-smoke-test <run-id>
```

Link that green run in the PR body — that, not hub CI, is the e2e proof.

- **A provider gotcha, not a module bug.** The meshStack Terraform provider HTML-escapes `>`, `<`
  and `&` in a `CODE` input and then reports *"Provider produced inconsistent result after apply"*.
  The building block handles any cloud-init — a VM ordered straight through the CLI with a `>`
  redirect in its cloud-init comes up fine; this bites only the provider's round-trip of the *test's*
  input. Keep the test's cloud-init clear of those characters: write files with `write_files`, not a
  shell redirect.

## That's the loop

Foundation → read the conventions → scaffold with the agent → register the definition → order and
verify → ship. The agent did the typing and the toil; you set it up and decided it was done. That's
the job.
