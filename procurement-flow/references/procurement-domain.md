# Procurement domain vocabulary → source-to-pay stages

Maps common e-proc / Indonesian procurement terms (seen in BRI iproc-5g style repos) to
standard source-to-pay stages. Use as a HINT list when clustering modules — not every
repo has every stage, and names vary.

## Canonical source-to-pay pipeline

1. **Vendor onboarding** — vendor registration/self-service.
2. **Qualification** — screening, document & legal checks.
3. **Sourcing / requisition** — need identified, budget, RfX.
4. **Award** — winner selected & ratified.
5. **Contract** — contract created & signed.
6. **Order** — PO issued.
7. **Receipt** — goods/services received & accepted.
8. **Invoice & pay** — invoice matched (3-way) and paid.
9. **Evaluation** — vendor performance scored; feeds back to qualification.

## Term glossary (ID / e-proc → meaning → stage)

| Term | Meaning | Stage |
|---|---|---|
| rekanan / vendor / mitra | supplier / business partner | 1 Onboarding |
| calon rekanan | prospective vendor | 1 Onboarding |
| bidang usaha | line of business / commodity class | 1 Onboarding |
| pre-screening / screening | initial eligibility check | 2 Qualification |
| SLIK / DHN / SKTS / SKT | credit & legal background checks | 2 Qualification |
| aktivasi / vendor-activation | activate vendor after checks pass | 2 Qualification |
| penetapan | ratification / official determination | 4 Award (also used elsewhere) |
| blacklist / sanksi / penetapan-sanksi | vendor sanction / ban | 2/9 (gate + eval) |
| RUR | usulan rekanan / vendor proposal-review flow | 2/3 |
| PTR | penetapan/permintaan flow (approval-bearing) | 3/4 |
| HPS | harga perkiraan sendiri (owner's estimate) | 3 Sourcing |
| procurement / pengadaan | the sourcing event itself | 3 Sourcing |
| bidder / vendor-bidder | participating supplier in an event | 3 Sourcing |
| penetapan (pemenang) | award / winner determination | 4 Award |
| contract-management / kontrak | contract lifecycle | 5 Contract |
| guarantee / jaminan / guarantee | bid/performance bond | 5 Contract |
| PO / purchase order | order issuance | 6 Order |
| BAST | berita acara serah terima (handover/receipt acceptance) | 7 Receipt |
| berita acara / template-berita-acara | official minutes/acceptance doc | 7 Receipt |
| invoice / invoice-management | supplier billing | 8 Invoice & pay |
| SAP | ERP integration (posting invoices/payments) | 8 Invoice & pay |
| evaluasi rekanan / evaluasi vendor | vendor performance evaluation | 9 Evaluation |
| aspek kinerja finansial | financial performance aspect | 9 Evaluation |

## Approval / workflow vocabulary (cross-cutting)

| Term | Meaning |
|---|---|
| maker / checker / signer | 3-role approval chain (create → verify → authorize) |
| approver-type | which role/level approves at a step |
| approval-history / activity-response | audit log of approval decisions |
| disposisi | routing/forwarding a task to another role |
| delegasi tugas | task delegation |
| tanggapan / comment / diskusi | reviewer feedback thread on an item |
| todo | pending-action queue per role |

## How to use

1. Cluster the API/service modules against the pipeline above.
2. Missing a stage? Note it in FLOW.md "Open questions" — the app may not implement it,
   or it lives in a separate backend repo.
3. Terms not in this table → infer from status constants + screen names, and add them.
