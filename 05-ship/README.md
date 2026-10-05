# Chapter 05 — The agent ships it

**What you do: review, then let it open the PR.**

The VM built and the agent logged in. Now it makes the change mergeable the way a hub contribution
is — and this is where you stop watching and start reviewing.

## What the agent does

- runs the hub's maturity scorecard and fixes the **module** to satisfy it (never the check):
  `node tools/scorecard/scorecard.mjs --module=stackit/server` — Core and Integration green;
- pushes the branch and opens the PR, with a body that states what was verified **live** (run
  SUCCEEDED, SSH worked) — the hub's CI is lint-only, so a real run is the only proof it works.

## What to watch for

- **The honest gap.** The agent should leave the **Testing** scorecard category red and *say why* in
  the PR, rather than fake an `e2e/` test. None of the STACKIT building blocks that take a service
  account as input
  ([`git-runner`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/git-runner),
  [`ske/cluster`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/ske/cluster),
  `git`, `container-registry`, `ai-llm`) ship a hub e2e — only
  [`service-account`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account)
  does, because its backplane self-federates. A real engineer documents that; so should the agent.
- **Your review is the gate.** Compare the result against
  [`solution/stackit-server/`](../solution/stackit-server/). The agent typed it; deciding it's right
  is still yours.

## That's the loop

Foundation → read the conventions → scaffold with the agent → register the definition → order and
verify → ship. The agent did the typing and the toil; you set it up and decided it was done. That's
the job.
