# Chapter 04 — The agent orders a VM and proves it works

**What you do: watch, and guide when it gets stuck.**

The agent now orders a building block against your STACKIT project — passing the service account from
chapter 00 — waits for the run, and verifies it. You're watching the loop that is the actual job of
an agentic platform engineer: order, read the run, fix forward, repeat until it's really working.

## What the agent is doing

- ordering the VM through the meshStack API (`STACKIT_SERVICE_ACCOUNT_EMAIL`, `machine_type`
  `g1a.1d`, a public IP, empty cloud-init) — there's no CLI create verb, so it POSTs;
- polling `meshstack buildingblock list` and, on failure, reading
  `meshstack buildingblockrun logs <run-uuid>` for the real error;
- once green, reading the `public_ip` and generated `ssh_private_key` outputs and doing an actual
  `ssh ubuntu@<public_ip>` — because "the run went green" and "I can log in" are different claims.

`bin/order-bb.sh` is the same sequence scripted end to end, if you'd rather run it than watch.

## What to watch for

- **The fix-forward loop.** When a run fails, a good agent reads the step log, changes one thing,
  pushes, and re-runs — it doesn't guess. That loop is the skill; notice it happening.
- **A misleading error.** If a STACKIT run dies at *"Unable to fetch images"*, that's an identity
  problem (the service account can't act on this definition), not a module or flavor bug — the fix
  lives in your chapter 00 foundation, not in the code.
- **Proof, not green.** The chapter isn't done when the run succeeds; it's done when the agent has
  SSH'd in. The private key comes back in the clear because meshStack has no sensitive outputs — the
  module unwraps it with `nonsensitive()` on purpose (see
  [`solution/stackit-server/buildingblock/outputs.tf`](../solution/stackit-server/buildingblock/outputs.tf)).

On to [chapter 05](../05-ship/).
