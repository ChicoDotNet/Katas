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

Results locally: 8 deterministic assertions, 300 independent cross-language season comparisons and specific behavioral RED. Swift 6.2.1, Python 3.13.5. Remote CI pending.

## Ninja evidence
Optional entrants have domain meaning (self-driving cars), not merely absent names. Those entrants still consume ranking positions. When tie-breaking is unspecified, document and test a stable rule before implementing. Do not infer generalizable language performance from one sample.

Provisional author score 88/100, difficulty 5/5. Not calibrated. [RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracles](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja observation](evidence/skill_review.md).
