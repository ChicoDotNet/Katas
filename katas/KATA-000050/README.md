# KATA-000050 — Killer Sudoku Helper (Fortran 2018)

Concept: https://github.com/exercism/problem-specifications/tree/main/exercises/killer-sudoku-helper. MIT repository: https://github.com/exercism/problem-specifications/blob/main/LICENSE. Original Fortran source/tests and independent Python oracle MIT; no upstream starter or canonical fixtures copied.

**Original contract:** cage length 1–9, target 1–45 and 9-bit exclusion mask for digits 1–9, where bit d-1 excludes digit d. Enumerate unique strictly ascending digits whose sum equals target, lexicographically sorted as base-10 numbers; impossible cages return empty, invalid requests are rejected. This is a cage helper, not a full Sudoku board solver or row/column/subgrid validator. Caller supplies the forbidden digits.

**Language:** Fortran 2018 bit intrinsics popcnt/btest and arrays make the 511 possible masks transparent. Python uses independent itertools.combinations rather than bit masks. Julia/Prolog were considered but not present in local toolchain. Cost bounded by 511*9 plus sorting; fixed-size results, no persistent state.

Run in this directory:

~~~sh
gfortran -std=f2018 -Wall -Wextra -Werror -fcheck=all -J /tmp -I /tmp src/cages.f90 tests/test_cages.f90 -o /tmp/killer-test
/tmp/killer-test
gfortran -std=f2018 -Wall -Wextra -Werror -fcheck=all -J /tmp -I /tmp src/cages.f90 src/main.f90 -o /tmp/killer-cli
python3 tests/differential.py /tmp/killer-cli
if KATA_RED=1 /tmp/killer-test >/tmp/killer-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/killer-red.log
~~~

Local: 12 deterministic cases, 2 invalids, 2525 differential scenarios, behaviorally failing RED. Provisional author score 89/100, difficulty 4/5, not calibrated. Evidence in evidence/. Ninja OBS-027.
