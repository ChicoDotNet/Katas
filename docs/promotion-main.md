# Stable main promotion — every 18 published katas

Effective 2026-10-17. Integration branch dev; stable release branch main.

Mandatory milestones: **18, 36, 54, 72 and 90** published in the pilot, then each further multiple of 18 if the independent transfer gate at 90 allows expansion. Earlier promotions are allowed.

Only katas actually marked published in dev with original or appropriately licensed source, RED/GREEN, independent oracle, Ninja review, exact-head CI and reviewed merge count. Local green/development_complete is not published.

At each milestone, capture dev and main SHAs, compare both directions and merge-base, audit code, licenses, catalog, Ninja, migrations and regression CI, then create a reviewed dev->main PR. Require CI green for the exact release candidate, review the merge diff, merge without force-push, and verify main HEAD after merge. **Do not stop writing additional independent katas while release CI is running.**

Important initial condition: main contains unique Dependabot commits and does not yet contain the kata catalog, whereas dev contains the pilot katas. Reconcile main-only changes before the first promotion instead of overwriting main.

Use tools/release_milestones.py to inspect separately checked-out dev and main catalogs. Missing main catalog counts as zero only for planning, not as proof of mergeability. If multiple milestones were missed, report all outstanding release debt. A main promotion does not replace the pilot's independent paired holdout experiment at 90.
