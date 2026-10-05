# Chapter 06 — Ship it

**Time: ~5 min. Credentials: GitHub.**

The VM built and you logged in. Now make the change mergeable, the same way a hub contribution is.

## Scorecard

The hub grades every module against a maturity scorecard. Run it and fix the module, never the check:

```bash
node tools/scorecard/scorecard.mjs --module=stackit/server
```

Core and Integration should be green. The one category you'll likely leave red is **Testing** — an
`e2e/` test — and that's a deliberate, honest gap worth explaining in the PR (see below).

## Open the PR

```bash
git push -u origin <your-branch>
gh pr create --base main --title "feat(stackit/server): STACKIT VM building block" --body "..."
```

In the body, state what you verified **live** (the run went SUCCEEDED, SSH worked) — the hub's CI is
lint-only, so a real run is the only proof the thing works.

## About the e2e gap

None of the STACKIT building blocks that take a service account as input
([`git-runner`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/git-runner),
[`ske/cluster`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/ske/cluster),
`git`, `container-registry`, `ai-llm`) ship a hub e2e — only
[`service-account`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account)
does, because its backplane self-federates. A hub e2e for a *consumed*-SA module would need to
federate an SA to the definition it builds, mid-test — exactly chapter 04's problem. That's why the
honest move is to document the gap, not fake a test that rots.
[`.agents/skills/e2e-test/SKILL.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/skills/e2e-test/SKILL.md)
is the reference if you decide to build one.

## That's the loop

Foundation → read the conventions → scaffold with the agent → definition → identity → order →
verify → ship. The agent did the typing; you did the parts that need judgement. That's the job.
