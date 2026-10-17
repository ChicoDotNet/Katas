# KATA-000035 — 0–1 Knapsack in Fortran

Canonical source: https://github.com/exercism/problem-specifications/tree/main/exercises/knapsack — Exercism MIT-licensed problem specifications. One MIT-documented illustrative scenario is adapted in our independently authored fixed tests; we did not copy canonical-data, starter implementation, or its test suite. New Fortran and Python code is MIT under root Katas license.

## Contract

Given integer capacity and individual items (weight, value), select each item **at most once**, maximizing value without exceeding capacity. Nonnegative weights (including zero), nonnegative values and empty inventory are supported. The local API caps capacity at 10,000 and items at 256 to avoid unbounded resource allocation; item value must not exceed 1,000,000,000. Invalid dimensions/ranges are rejected rather than silently truncated.

A one-dimensional descending-capacity DP visits each item once. Updating in ascending order would incorrectly permit reuse of the same object (unbounded knapsack). Reverse iteration remains valid for zero-weight items: their value is added once at each capacity.

## Choice of language

Fortran has strong multidimensional/numeric-array semantics and straightforward 1-based item iteration alongside 0-based capacity indexing. This illustrates a useful optimization outside its traditional scientific-computing setting. C/Rust/Julia could also express DP, but Fortran is already part of Genkidama and a readily executable GCC-family language. An independent Python oracle enumerates complete subsets rather than using DP.

## Reproduce

~~~sh
cd katas/KATA-000035
mkdir -p /tmp/ninja-knapsack-green /tmp/ninja-knapsack-red
gfortran -std=f2018 -Wall -Wextra -Werror -fcheck=all -J/tmp/ninja-knapsack-green src/knapsack.f90 tests/test_knapsack.f90 -o /tmp/ninja-knapsack-green/test
/tmp/ninja-knapsack-green/test
gfortran -std=f2018 -Wall -Wextra -Werror -fcheck=all -J/tmp/ninja-knapsack-green src/knapsack.f90 src/main.f90 -o /tmp/ninja-knapsack-green/cli
python3 tests/differential.py /tmp/ninja-knapsack-green/cli
gfortran -std=f2018 -Wall -Wextra -Werror -J/tmp/ninja-knapsack-red tests/red_stub.f90 tests/test_knapsack.f90 -o /tmp/ninja-knapsack-red/test
if /tmp/ninja-knapsack-red/test >/tmp/knapsack-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral' /tmp/knapsack-red.log
~~~

Local gfortran 14.2 + Python 3.13: **8 acceptance scenarios, 500 independently enumerated subsets, and a behaviorally failing compiled RED**. One initially incorrect hand-computed expected total was corrected from 30 to 35 after confirming that items worth 20 and 15 can coexist; expected-value audit preceded GREEN. A warning in the RED stub was fixed without disabling -Werror.

Author-provisional score 90/100 and difficulty 5/5 (knapsack complexity, edge cases and single-use invariant); ratings are not independently calibrated. Time O(N×C), space O(C), within declared input bounds. Real-world overflow, optimization for enormous capacities, negative values and fractional weights are not supported.

Evidence: [RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md).
