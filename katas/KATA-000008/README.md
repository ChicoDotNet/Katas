# KATA-000008 — Race Car Leaderboard (Swift 6)

Source exercise: [Kata-Log Race Car — Leaderboard](https://kata-log.rocks/race-car-katas-leaderboard). The Kata-Log page is public-domain, but the linked external starter sources may carry independent licenses. This solution uses **original code and test fixtures only**, MIT-licensed; it is a similar testability exercise, **not** a refactor of Emily Bache's existing source.

## Original contract
Aggregate driver points across multiple race finishing orders. A **nil** entry represents a self-driving car, occupying a classified position but earning **no human driver points**. Each race must contain 1–10 participants; named drivers cannot appear twice in one race. Positions earn locally chosen Formula-style points: 25,18,15,12,10,8,6,4,2,1. Drivers sort by descending total points, then alphabetically on ties. Empty season and all-autonomous races have an empty leaderboard.

These scoring constants and tie-handling decisions are authored assumptions, not claims about the upstream starter's interface/logic. Unknown driver names must be nonblank and whitespace-free.

## Why Swift
Strong value types, optionals for self-driving entries and stable deterministic sorted output illustrate domain expressivity while staying agnostic of specific OO mock frameworks. This kata tests an algorithmic core independently instead of inheriting a legacy upstream implementation. Languages considered: Python (also used by our differential oracle), Kotlin, and Scala; Swift broadens Genkidama toolchain coverage.

## Reproduce
~~~sh
cd katas/KATA-000008
swiftc -swift-version 6 -O src/leaderboard.swift tests/test_leaderboard.swift -o /tmp/ninja-swift-test
/tmp/ninja-swift-test
swiftc -swift-version 6 -O src/leaderboard.swift src/cli.swift -o /tmp/ninja-swift-cli
python3 tests/differential.py /tmp/ninja-swift-cli
swiftc -swift-version 6 -D KATA_RED src/leaderboard.swift tests/test_leaderboard.swift -o /tmp/ninja-swift-red
if /tmp/ninja-swift-red >/tmp/ninja-swift-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/ninja-swift-red.log
~~~

Historical local checkpoint: 8 deterministic assertions, 300 cross-language season comparisons and specific behavioral RED (Swift 6.2.1, Python 3.13.5). The original kata was subsequently published; its remote certification is tracked in the catalog and GitHub CI, not in this historical paragraph.

## Ninja evidence
Optional entrants have domain meaning (self-driving cars), not merely absent names. Those entrants still consume ranking positions. When tie-breaking is unspecified, document and test a stable rule before implementing. Do not infer generalizable language performance from one sample.

Provisional author score 88/100, difficulty 5/5. Not calibrated. [RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracles](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja observation](evidence/skill_review.md).

## 2026-10-28 additive hardening — algebraic histogram and metamorphic checks

**Domain invariants.** Each race contributes fixed points by finishing *position*; `nil` consumes a position but not points. Driver names are unique within a race. Scores add across races, and the leaderboard is sorted by descending total then ascending name. Input order of races must not matter.

**Language decision (before CI inspection).** Swift remains the implementation and native RED/GREEN language because its optionals make autonomous positions explicit; Kotlin would express nullability comparably but add JVM-specific ceremony, Scala would favor higher-order collections over Swift's value semantics, and Python would hide the language-specific optional contract. No implementation migration or new KATA-ID. For the new oracle, Go's fixed-size `[10]int` and explicit maps make a *driver-by-position frequency matrix* natural. Ruby would be concise but would repeat the existing imperative Python oracle too closely; Haskell would express the fold algebraically but requires a new compiler here with no greater independence than the histogram model. Go was selected for its reference structure, **not** because of existing workflows.

| Layer | Language | Independent technique | Command |
| --- | --- | --- | --- |
| Production | Swift 6.2 | Per-race running score totals, sorted standings | `swiftc -swift-version 6 -O src/leaderboard.swift src/cli.swift -o /tmp/leaderboard` |
| Native RED/GREEN | Swift 6.2 | Behaviorally wrong RED plus native contract assertions | Original `swift-katas.yml` steps above |
| Existing differential | Python 3 | Per-race accumulation (structural similarity risk) | `python3 tests/differential.py /tmp/leaderboard` |
| New reference | Go 1.23 | Build finish-position histograms, then dot-product with points | `bash tests/histogram-run.sh` |
| New metamorphic | Go 1.23 → Swift | Race permutation, autonomous-only append, trailing nil, bijective renaming, partition additivity | Same script |
| Mutation | Swift 6.2 + Go | Recompile wrong second-place points and reversed tie rule; oracle must reject both | Same script |

**Verification strategies compared.** The original Python per-race fold risks reproducing the Swift accumulator's bugs. The new histogram/dot-product approach changes the reference structure and supports algebraic partition-additivity; metamorphic relations add checks that require no expected score calculation for permutations, nil-only races, trailing nil, or bijective renaming. These are complementary, not translations of the same algorithm. Shared risk remains in the authored point table, sorting contract, deterministic generator and Swift CLI JSON encoding. The seeded suite does not prove all possible seasons, race-free execution or compatibility with the external legacy starter.

**Actual local execution:** Swift 6.2.1 / Go 1.23.2: 1,542 Swift differential comparisons, 880 metamorphic invariants, 220 partition-additivity witnesses, 2 targeted nil/tie witnesses, 2/2 compiled mutants detected; original Swift RED/GREEN and 300 Python comparisons passed. See [local evidence](evidence/histogram-local-2026-10-28.txt) and [Ninja review](evidence/histogram-skill-review-2026-10-28.md). CI must run on the exact PR head before this hardening can be certified or merged. Existing publication status is unchanged.
