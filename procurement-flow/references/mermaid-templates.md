# Mermaid templates for FLOW.md

Copy, then replace placeholders with evidence-backed nodes/edges. Keep labels short.

## 1. Source-to-pay pipeline (top of doc)

```mermaid
flowchart LR
  A[Vendor onboarding] --> B[Qualification / screening]
  B --> C[Activation]
  C --> D[Sourcing / procurement]
  D --> E[Award / penetapan]
  E --> F[Contract]
  F --> G[PO]
  G --> H[Receipt / BAST]
  H --> I[Invoice & pay]
  I --> J[Evaluation]
  J -.feedback.-> B
```

Delete stages the repo does not implement; keep the arrows honest.

## 2. Per-entity state machine

```mermaid
stateDiagram-v2
  [*] --> Draft
  Draft --> Submitted: submit (screen X / POST .../store)
  Submitted --> UnderReview: checker opens
  UnderReview --> Approved: signer approves (PUT .../approval)
  UnderReview --> Rejected: reject (PUT .../approval)
  Rejected --> Draft: revise
  Approved --> [*]
```

Every edge label = trigger (screen or endpoint). States come from the status constant set.

## 3. Approval chain (maker–checker–signer)

```mermaid
flowchart LR
  M[Maker: create/submit] --> C{Checker: verify}
  C -- reject --> M
  C -- ok --> S{Signer: authorize}
  S -- reject --> M
  S -- ok --> D[Done / next stage]
```

Annotate each node with the endpoint / approver-type constant that governs it.

## Rendering note

GitHub renders mermaid in .md natively. If the user needs a static image, offer to
export via an Artifact or a local mermaid-cli step — don't assume it.
