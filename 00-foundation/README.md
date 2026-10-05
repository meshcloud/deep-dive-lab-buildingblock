# Chapter 00 — Stand up a STACKIT foundation

**Time: ~15 min, once. Credentials: meshStack admin + a STACKIT organization.**

Everything after this chapter runs against *your* meshStack, so first give yourself a STACKIT
foundation to build on. The hub ships one as a reference architecture — you deploy it once and get a
self-service STACKIT platform: a resourcemanager folder, a foundation project with a project-creation
service account, and the **STACKIT Project** platform with a default landing zone. That's the same
machinery a real cloud-foundation team would run; here it's one `tofu apply`.

## Deploy it

In a checkout of [meshstack-hub](https://github.com/meshcloud/meshstack-hub):

```bash
cd reference-architectures/stackit-landingzone
cp terraform.tfvars.example terraform.tfvars   # fill in: meshStack workspace, STACKIT org id, creds
tofu init
tofu apply
```

The ref-arch's own [`README.md`](https://github.com/meshcloud/meshstack-hub/tree/main/reference-architectures/stackit-landingzone)
is the authority on its inputs — read it, don't guess. The always-on result is a sandbox landing
zone application teams can immediately request STACKIT projects from, plus the **STACKIT Service
Account** building block (service account + project roles + workload identity federation).

## Get the two things the later chapters need

1. **A STACKIT project (tenant).** Order the **STACKIT Project** building block (in the workspace,
   against the new platform). When it succeeds, note its **tenant uuid** and STACKIT **project id** —
   `meshstack buildingblock list -o json` shows them in the block's `targetRef` and outputs.
2. **A service account with `editor` on that project.** Order the **STACKIT Service Account**
   building block with role `editor`; note its **email** from the output.

Record both in the lab's var-file:

```bash
cp ../deep-dive-lab-buildingblock/demo.tfvars.example demo.tfvars   # adjust path to this repo
# set tenant_uuid and sa_email
```

## What this buys you

You now have, in your own meshStack, exactly the prerequisites the dry run depended on: a STACKIT
project to deploy into and an `editor` service account to act as. The one thing still missing is a
link between that service account and the building block you haven't built yet — that's
[chapter 04](../04-identity/), and it's deliberately a separate step because of *when* it has to
happen. On to [chapter 01](../01-orientation/).
