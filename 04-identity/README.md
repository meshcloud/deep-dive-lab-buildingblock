# Chapter 04 — Identity (you already have it)

**Time: ~1 min. Credentials: none here — set up in chapter 00.**

The VM building block runs as a **STACKIT service account**, passed in as `STACKIT_SERVICE_ACCOUNT_EMAIL`.
You already created that account with the `editor` role and its workload-identity federation as part
of your foundation ([chapter 00](../00-foundation/)) — so there's nothing to do now except hand its
email to the agent. The chapter 02 prompt already asks you for it.

> One line worth knowing: STACKIT federation is tied to the building block definition, so the service
> account you set up has to trust the definitions you deploy. The landing zone's
> [Service Account](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-service-account)
> and [Service Account Federation](https://hub.meshcloud.io/platforms/stackit/definitions/stackit-service-account-federation)
> building blocks are what establish that trust. If a run ever fails with a misleading
> *"Unable to fetch images"*, that's this link missing — not a role or module problem.

On to [chapter 05](../05-order-and-verify/).
