# Chapter 04 — Identity: federate the service account to your definition

**Time: ~5 min. Credentials: meshStack + STACKIT. This is the chapter that catches everyone.**

You have a definition (chapter 03) and a service account with `editor` on the project (chapter 00).
They still can't work together, and the reason is the one genuinely non-obvious thing in the whole
lab.

## The rule

**STACKIT workload-identity federation is per building block definition.** A run presents the
runner's identity; the STACKIT service account only trusts that identity if it has been **federated
to the specific definition** the run belongs to. The definition you created in chapter 03 is brand
new, so no service account trusts its runs yet — even one with `owner` on the project.

The failure is disguised. A run with an unfederated SA dies at the first STACKIT call and the
provider reports:

```
Error: List images
Unable to fetch images
```

That looks like a missing role or a module bug. It is neither — it's a **401, mis-rendered**. Do not
reach for a bigger role; `editor` already includes `iaas.server.create`. The fix is federation. (The
"Runner identity" section of
[`meshstack-integration.md`](https://github.com/meshcloud/meshstack-hub/blob/main/.agents/references/meshstack-integration.md)
is the background.)

## Why it can't be a prereq

Federation names the definition's uuid — which doesn't exist until chapter 03 creates it. So this
step is necessarily *after* the definition and *before* the first order. That ordering is the whole
reason it's its own chapter.

## Do it

Order the **STACKIT Service Account Federation** building block against your tenant — it's a
published building block on the [hub](https://hub.meshcloud.io), so if your foundation doesn't
already offer it, **Add to meshStack** with one click first. Order it with:

- `service_account_email` = your `editor` SA from chapter 00, and
- `federated_building_block_definitions` = `["<the new BBD uuid>"]` — a real HCL list, not a bare
  string (a bare string fails with *"list of string required, but have string"*).

When it succeeds, the SA trusts runs of your definition. See
[`modules/stackit/service-account-federation`](https://github.com/meshcloud/meshstack-hub/tree/main/modules/stackit/service-account-federation)
for what it does under the hood. On to [chapter 05](../05-order-and-verify/) — now the VM will
actually build.
