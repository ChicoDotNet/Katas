# KATA-000032 — Alphametics (Python 3.13)

Original challenge: [Exercism problem-specifications / alphametics](https://github.com/exercism/problem-specifications/tree/main/exercises/alphametics). Upstream repository license: [MIT](https://github.com/exercism/problem-specifications/blob/main/LICENSE). **No source, existing tests, or starter implementations were copied.** This specification, implementation, tests and documentation here are independently authored and covered by the repository MIT license.

## Contract

Given an uppercase-letter sum such as \`SEND + MORE = MONEY\`, assign each distinct letter a **different decimal digit** so that the numerical sum is correct. Return one mapping, or \`None\` if impossible. **Only multi-digit words disallow a leading zero**: a one-letter word can represent zero. Reject malformed expressions. A puzzle with more than ten unique letters cannot be solved under decimal injection. The result is an arbitrary valid solution rather than a promise to enumerate all possibilities.

## Language choice

Python suits a compact constraint solver, recursion and dictionary-based reversible assignments. Prolog would be especially expressive for constraint logic and CLP(FD), but that executable is not confirmed in the available environment. Haskell/Scala are plausible alternatives. A brute-force Python algorithm used only in the independent test oracle searches all distinct-digit permutations, whereas the production algorithm applies *column-wise carry constraints* to prune invalid assignments early. The reference implementation does not use an external solver.

## Reproduce

~~~sh
cd katas/KATA-000032
python3 -m unittest discover -s tests -v
python3 tests/differential.py src/cli.py
# A deliberately wrong solver must fail a behavior assertion:
if KATA_RED=1 python3 -m unittest discover -s tests > /tmp/alphametics-red.log 2>&1; then exit 1; fi
grep -q 'FAIL: test_send_more_money' /tmp/alphametics-red.log
~~~

Local Python 3.13.5: six unit-test groups passing (including unique \`SEND+MORE\`, one-letter zero, invalid forms and unsatisfiable problems), **84 oracle comparisons**. The oracle uses naive exhaustive permutations and verifies whether a solution exists, not a matching choice of solution, because many puzzles have multiple correct digit assignments. RED uses a compilable/interface-preserving solver returning an empty mapping that fails the correct acceptance contract.

Worst-case computational search remains exponential in distinct letters (maximum ten), although per-column carries prune the tree. No claim of a polynomial-time solver, distributed constraint engine or performance comparison across languages.

Provisional author difficulty **5/5**, rubric **93/100**; not independently calibrated. This kata extends the problem-solving portfolio to combinatorial constraint search.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [Independent oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md)
