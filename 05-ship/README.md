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

## What to watch for

- **Closing the Testing gap.** Most STACKIT building blocks that take a service account as input
  ([`git-runner`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/git-runner),
  [`ske/cluster`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/ske/cluster),
  `git`, `container-registry`, `ai-llm`) ship **no** hub e2e, because a hub-mode test has to stand up
  the run's identity itself — the same per-definition WIF federation you did by hand in chapter 04.
  Do that inside the test (as
  [`service-account`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account)'s
  self-federating backplane does for free) and the gap closes: this module ships an `e2e/` and proves
  it green in CI. Nothing is faked — the test provisions a real VM and tears it down. Where an agent
  genuinely *can't* stand up that identity, leaving the category red and saying why in the PR is still
  the honest move.
- **Your review is the gate.** Compare the result against
  [`solution/stackit-server/`](../solution/stackit-server/). The agent typed it; deciding it's right
  is still yours.

## The smoke test

The `e2e/` mirrors [`stackit/secrets-manager`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/secrets-manager/e2e):
a mode-agnostic `main.tf`, a `modes/hub` that builds the definition from the pushed branch and
federates it, a `modes/foundation` that looks the published definition up, and a
`tests/stackit_server.tftest.hcl` that asserts the run SUCCEEDED and checks the `public_ip`,
`server_id`, `ssh_username`, `ssh_command` and `ssh_private_key` outputs — passing a personal
cloud-init so the `user_data` path runs for real.

It can't run locally (hub CI is lint-only); you dispatch it in the smoke-test repo against the PR
branch, then link the green run in the PR body — that, not hub CI, is the e2e proof:

```bash
gh workflow run smoke-test.yml -R meshcloud/meshstack-smoke-test \
  -f module=stackit/server -f meshstack_hub_ref=refs/pull/<nr>/head
gh run watch -R meshcloud/meshstack-smoke-test <run-id>
```

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
