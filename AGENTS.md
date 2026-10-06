# Agent instructions for this repository

This is a workshop repo about **working as an agentic platform engineer**: building a meshStack
building block with an agent and driving it live from the CLI. Each numbered directory is one
chapter; its `README.md` states what it teaches. The building block itself is built in
[meshstack-hub](https://github.com/meshcloud/meshstack-hub) during the session — this repo is the
runbook plus a finished [`solution/`](solution/).

Read this file before helping in a session. It exists so an agent is useful here without being told
the same things every time — which is the actual point of the lab.

## Where the real instructions live

When the task is to build or change a building block, the authority is the **meshstack-hub** repo,
not this one. Start from its `CLAUDE.md` and load only the referenced files that match what you
touch. [`01-orientation/README.md`](01-orientation/README.md) is the reading list. Never invent a
hub convention from memory — open the file.

## How to verify your work

Never hand back building block code you have not checked.

```bash
# in meshstack-hub, in the module you changed:
tofu -chdir=modules/stackit/server/buildingblock validate
node tools/scorecard/scorecard.mjs --module=stackit/server
```

A building block *definition* and a real *run* are the only proof it works end to end — CI in the
hub is lint-only. Create the BBD (chapter 03), order a building block (chapter 05), and read the run:

```bash
meshstack buildingblock list -o json
meshstack buildingblockrun logs <run-uuid>
```

`bin/order-bb.sh` automates create-definition → federate → order → verify when you want it hands-off.

## Conventions carried over from the dry run

These are the things that cost us time the first time. Treat them as rules.

- **STACKIT WIF federation is per building block definition.** A service account used by a STACKIT
  building block needs the `editor` role on the project **and** must be federated to the specific
  definition the run executes. Miss the federation and every run fails — the STACKIT provider
  misreports it as *"Unable to fetch images"*, which looks like a role or module bug and is neither.
  Reach for federation (chapter 04), never a bigger role; `editor` already includes `iaas.server.create`.
- **A pushed branch is what runs.** The building-block runner clones `buildingblock/` from GitHub at
  `var.hub.git_ref`. An unpushed local edit changes nothing about a run. Commit and push before
  ordering or re-running.
- **meshStack has no sensitive outputs.** A value a provider marks sensitive (a generated private
  key) won't export unless unwrapped with `nonsensitive()`. Gate that with `try(...)`, not
  `x != null` — a null-check on a sensitive object is itself sensitive and re-taints the output.
- **Flavor `g1a.1d` exists in `eu01`.** Older `g1.1`-style names may not; don't default to a guess.
- **Tear-down needs delete rights.** Deleting a building block runs a delete-run that destroys the
  cloud resources; if the login or API key lacks delete permission, do it in the meshPanel UI.
- **The meshStack provider HTML-escapes `CODE` inputs.** A `CODE` value containing `>`, `<` or `&`
  makes the Terraform provider report *"Provider produced inconsistent result after apply"* (it
  unicode-escapes them at plan but returns them literal after apply). The building block is fine; it bites only
  the provider round-trip, so it shows up in an `e2e/` smoke test, not in a CLI-ordered run. Keep
  e2e cloud-init clear of those characters — `write_files`, not a shell redirect.

## Conventions for this repo's own content

- Chapters teach in their `README.md`; keep code comments for the non-obvious constraint, not the
  narration.
- No `provider "meshstack"` block anywhere, and no API key or secret in any file. Authentication is
  passwordless: `meshstack login` ([meshstack-cli](https://github.com/meshcloud/meshstack-cli)) does
  a browser/OIDC login once, and both the CLI and the Terraform provider ride that profile. Never
  introduce a stored credential.
- `bin/env.sh` holds credentials only and is gitignored; per-run ids go in `demo.tfvars` (gitignored,
  `demo.tfvars.example` committed).
- `solution/` is a snapshot of the finished module for comparison — it is not sourced or run from here.
