# KATA-000046 — Word Search (Swift 6)

Source: [Exercism Word Search](https://github.com/exercism/problem-specifications/tree/main/exercises/word-search) ([MIT](https://github.com/exercism/problem-specifications/blob/main/LICENSE)). This implementation, tests and oracle are independently written MIT source; no canonical upstream assets or starter code imported.

Rectangular uppercase ASCII grid, search each word in eight directions. No wrapping. Coordinates are zero-based [row,column]. If multiple occurrences exist, choose the earliest row, then column, then direction **N, NE, E, SE, S, SW, W, NW**. Missing words have nil coordinates; malformed grids and empty/nonuppercase words are rejected. This tie-break is locally specified, not copied from source fixtures.

Swift value structs and optional coordinates make error/success representation explicit. Python uses independent coordinate enumeration for differential tests. Complexity O(words×height×width×directions×maxWordLength).

~~~sh
cd katas/KATA-000046
swiftc -swift-version 6 src/Search.swift tests/TestSearch.swift -o /tmp/word-test
/tmp/word-test
swiftc -swift-version 6 -O src/Search.swift src/Main.swift -o /tmp/word-cli
python3 tests/differential.py /tmp/word-cli
swiftc -swift-version 6 -D KATA_RED src/Search.swift tests/TestSearch.swift -o /tmp/word-red
if /tmp/word-red >/tmp/word-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/word-red.log
~~~

Local: 11 fixed directional assertions, 2 validation checks and 400 independently checked boards. An incorrectly spelled expected reverse diagonal was corrected before GREEN. RED compiles and fails for missing expected matches. Author-only provisional difficulty 4/5 and score 89/100; not calibrated.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md).


## Geometric hardening — 28-oct-2026 (additive, same KATA-ID)

| Layer | Language | Algorithm / verification technique |
|---|---|---|
| Production | Swift 6 (unchanged) | Eight-direction row-major search and explicit optional endpoints |
| RED/GREEN | Swift 6 | Native behavioral assertions, actual KATA_RED compile/failure |
| Original differential oracle | Python 3 | Enumerate all coordinates/directions, check deterministic tie-break |
| New independent oracle | Go 1.23 | Construct a unique path *before* running Swift, transform endpoints under all eight dihedral symmetries, verify path witnesses |
| Mutation gate | Swift 6 + Go 1.23 | Compile and detect missing diagonal and incorrect endpoint mutants |

The new oracle contrasts **constructive/metamorphic geometry** against the existing **brute-force enumeration**. A rotated/reflected board preserves *existence*, but its row-major tie-break may choose a different occurrence; only **uniquely planted** words assert transformed endpoints. Go was selected for clear bounded byte-grid transformations, not because of an existing workflow. Haskell and Ruby were considered; neither provides an evidenced advantage here. Shared risk: row/column and direction conventions. The constructive model avoids translating the Swift search loop, while Python still covers tie-break cases.

Local command: `bash tests/geometry-run.sh` (Swift 6.2.1, Go 1.23.2, Python 3.13.5). Local evidence: [geometry run](evidence/geometry-local-run-2026-10-28.txt), [full audit and Ninja decision](evidence/geometry-hardening-2026-10-28.md). The existing Python suite is still run by the original workflow; the new script does not claim to execute it. No source implementation change or new publication; remote certification requires exact-head CI and independent review.
