# Ninja Batch EXP-001 — second multi-kata throughput checkpoint

Date: 2026-10-17. Started on the previous **8/90** published pilot baseline. Four development-complete katas were authored **sequentially** while CI for earlier commits ran independently.

| Kata | Language | Local fixed checks | Independent differential scenarios | Original-source-only |
|---|---|---|---|---|
| KATA-000011 Gilded Rose | Kotlin 1.9 | 11 | 1,445 | yes |
| KATA-000009 Bowling | C11 | 8 | 600 | yes |
| KATA-000028 The Lift | Go 1.23 | behavioral tests | 300 | yes |
| KATA-000019 Parallel Change | Java 21 | 11 | 400 | yes |

Total 2,745 differential scenarios, each with a separately implemented Python oracle. Each kata includes a deliberate **behavioral RED**, original GREEN implementation, independent check, rights/provenance note, language rationale and bounded Ninja skill review.

The catalog increased from 31 to **61** records. The 30 new Exercism entries are **discovered-only** metadata; the full 152-entry source index is a future scan horizon, not claimed as audited or ingested. Conceptual deduplication and per-asset rights checks remain necessary.

Ninja version v0.1.7 to **v0.1.11** with four new observations OBS-010 to OBS-013. These changes are not evidence of a causal gain in transfer speed or success rates.

CI certification: 13 of 13 workflows green for exact code SHA 166aa60ddec14ab3612404821edcc36f2578d3b5; PR #13 merged to dev at b71b1a43820db3df79be4e66218f62b2f104a234. Published count after catalog evidence promotion: **12/90**, conditional on merging the metadata PR. Main unchanged.
