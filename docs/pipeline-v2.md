# Development/CI overlap — experiment extension 2026-10-17

The new pipeline is **single-author serial development with asynchronous CI**. A kata must have an implemented solution, verified local RED, GREEN, a structurally independent oracle, authorship/provenance notes, and Ninja review **before** work begins on the next. It may then set `development_complete: true` and stay `green` until remote CI has reported results.

GitHub-hosted CI may run in parallel with creation of the following kata. This saves wait time but MUST NOT be taken to mean concurrent or incomplete kata development.

## Catalog scanning

Every source scan adds all new canonical candidate records with stable IDs, source URLs and provisional fingerprints/difficulty, status `discovered`. The scan manifest records how many were considered, unique and rejected. Rights and rubric are audited **per candidate** before marking eligible. Scan records are append-only and independently reviewable. This first expanded scan covers the 31 exercises listed by Kata-Log, including the four prior published ones.

## Promotion

`green + development_complete` = independently tested locally, GitHub CI pending. `verified` = GitHub CI green and evidence. `published` = integrated reviewed PR and explicit skill review. Already-published count is NOT affected by overlapping work.

If the current PR's CI fails, fix it and/or open a follow-up corrective PR. Do not hide the failure, and do not merge a partially tested branch.
