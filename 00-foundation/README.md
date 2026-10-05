# Chapter 00 — Stand up a STACKIT foundation

**Time: ~15 min, once. Credentials: meshStack admin + a STACKIT organization.**

Everything after this chapter runs against *your* meshStack, so first give yourself a STACKIT
foundation to build on. The hub ships one as a reference architecture — you deploy it once and get a
self-service STACKIT platform: a resourcemanager folder, a foundation project with a project-creation
service account, and the **STACKIT Project** platform with a default landing zone. That's the same
machinery a real cloud-foundation team would run; here it's one `tofu apply`.

## Deploy it

**The easy way — add it straight to meshStack.** Open the ref-arch on the hub and click
**Add to meshStack**:

→ https://hub.meshcloud.io/reference-architectures/stackit-landingzone

meshStack walks you through the inputs (your workspace, the STACKIT organization and credentials)
and deploys it for you — no local checkout, no `tofu` on your machine.

**The local way — if you'd rather run the Terraform yourself**, in a checkout of
[meshstack-hub](https://github.com/meshcloud/meshstack-hub):

```bash
cd reference-architectures/stackit-landingzone
cp terraform.tfvars.example terraform.tfvars   # fill in: meshStack workspace, STACKIT org id, creds
tofu init && tofu apply
```

Either way, the ref-arch's own [`README.md`](https://github.com/meshcloud/meshstack-hub/tree/main/reference-architectures/stackit-landingzone)
is the authority on its inputs. The always-on result is a sandbox landing zone application teams can
immediately request STACKIT projects from, plus the **STACKIT Service Account** building block
(service account + project roles + workload identity federation).

## Get the two things the later chapters need

1. **A STACKIT project (tenant).** Order the [**STACKIT Project (Starterkit)**](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-stackit-project-starterkit)
   building block — the self-service project entry the landing zone composes. When it succeeds, note
   its **tenant uuid** and STACKIT **project id** — `meshstack buildingblock list -o json` shows them
   in the block's `targetRef` and outputs.
2. **A service account with `editor` on that project.** Order the [**STACKIT Service Account**](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-service-account)
   building block with role `editor`; note its **email** from the output.

The [**STACKIT Service Account**](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-service-account)
and the [**Service Account Federation**](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-service-account-federation)
(the WIF piece you'll use in [chapter 04](../04-identity/)) are published building blocks on the
hub — if your foundation doesn't already offer one, open it and **Add to meshStack** with one click,
the same as the landing zone. Their sources are
[`modules/stackit/service-account`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account)
and [`modules/stackit/service-account-federation`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account-federation).

Record both ids in the lab's var-file:

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
