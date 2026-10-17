# Ninja experiment checkpoint — six consecutive katas

Date: 2026-10-17. Starting state: **20/90 published**, catalog 61, Ninja v0.1.19, stable main at release 001. New katas developed **sequentially**, with behavior RED, local GREEN, independent oracle, source provenance and Ninja review completed before beginning each successor. Remote CI overlapped authoring.

| Kata | Language | Independent oracle cases | Observation |
|---|---|---:|---|
| KATA-000037 Reactive Cells | JavaScript | 360 | OBS-021 stable-state callback delivery |
| KATA-000036 Poker | Ruby | 760 | OBS-022 complete tie-breaking keys |
| KATA-000048 Connect Hex | C++20 | 1500 | OBS-023 connectivity / geometric adjacency |
| KATA-000054 Satellite | Java 21 | 905 | OBS-024 generator-first tree reconstruction |
| KATA-000045 Two Bucket | Go | 1200 | OBS-025 independently verify optimality and witness |
| KATA-000052 Zipper | TypeScript | 420 | OBS-026 immutable breadcrumbs and focus |

**5,145 independently checked scenarios**. Source links point to MIT-licensed Exercism problem specifications; solutions, tests and differential oracles were independently authored, not copied. Scores/difficulties are **provisional author estimates**, not validated by multiple raters or a held-out panel.

PR #29: https://github.com/ChicoDotNet/Katas/pull/29; exact source head `672cdd1eaf4e1c00d9704c2c4133ee2610edff53`, **28/28** remote workflows GREEN; merged to dev as `8edd7ef16f450f8d0759b9f00323c54d6cfea09c`. Later publication metadata PR brings the catalogue to **26/90**, once merged. Ninja advances to **v0.1.25**. `main` stays at 20 published until next stable release (mandatory at 36).

Known engineering repairs: numeric bounds in JS random generator, bad duplicate-card fixture in Python, strict-warning red variant in C++ Hex, Go CLI package split, and GitHub-only Python operator typo corrected after CI failure. These count as retrabalho and must not be hidden to inflate the claimed pace.

**Interpretation:** six locally completed katas in one conversation iteration is progress in engineering throughput, but does not prove learning transfer or a trend toward nine per turn. Active engineering duration, CI duration, correction cycles, difficulty calibration and independent unseen-problem performance must be tracked before causal conclusions.
