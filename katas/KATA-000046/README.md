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
