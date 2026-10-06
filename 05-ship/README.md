# Chapter 05 — The agent ships it

**What you do: review, then let it open the PR.**

The VM is up and the agent logged in. Now it makes the change mergeable the way a hub contribution
is — and here you stop watching and start reviewing.

## What the agent does

- **Scorecard green.** Runs the hub's maturity scorecard and fixes the *module* to satisfy it (never
  the check): `node tools/scorecard/scorecard.mjs --module=stackit/server`.
- **Adds a smoke test** under `e2e/`, using the hub's
  [`e2e-test`](https://github.com/meshcloud/meshstack-hub/tree/main/.agents/skills/e2e-test) skill,
  and proves it by running it in CI (below).
- **Opens the PR**, with a body that says what was verified for real — run SUCCEEDED, SSH worked,
  smoke test green. Hub CI only lints, so a real run is the only proof the block works.

## What the smoke test is

A smoke test is one throwaway end-to-end run: it **really orders a VM, checks it, and deletes it
again**. Green means a real server came up, answered, and was torn down.

It can't run in the hub's own CI (that only lints), so it lives in a separate repo,
[`meshstack-smoke-test`](https://github.com/meshcloud/meshstack-smoke-test), which has a live
meshStack and a throwaway STACKIT project to build into. There it runs `tofu test` in the module's
`e2e/` directory — **apply → check → destroy**.

You don't wire any of that up. The repo hands the test everything it needs about the environment —
which workspace, which STACKIT project and tenant, and a unique id to name things after — in one
bundle, so the test code itself holds no ids and no secrets. The module's `e2e/` is just two shapes
of the same test: one that builds the definition from your branch (the one CI runs) and one that
orders against an already-published definition. [`stackit/secrets-manager`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/secrets-manager/e2e)
is the template to copy.

## Running it

You dispatch it against your PR branch — which must be **pushed**, because the runner pulls
`buildingblock/` from GitHub, not from your disk:

```bash
gh workflow run smoke-test.yml -R meshcloud/meshstack-smoke-test \
  -f module=stackit/server -f meshstack_hub_ref=refs/pull/<nr>/head
gh run watch -R meshcloud/meshstack-smoke-test <run-id>
```

Then link that green run in the PR — that, not hub CI, is the proof it works end to end.

**One gotcha worth knowing.** The meshStack Terraform provider mangles `>`, `<` and `&` inside a
`CODE` input and then fails with *"Provider produced inconsistent result after apply"*. The building
block is fine — a VM ordered through the CLI with a `>` in its cloud-init works; it only bites the
test's round-trip. So keep the test's cloud-init free of those characters: use `write_files`, not a
`>` redirect.

## That's the loop

Foundation → read the conventions → scaffold with the agent → register the definition → order and
verify → ship. The agent did the typing and the toil; you set it up and decided it was done. That's
the job.
