#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build evidence
# Real compiler for both RED and GREEN; RED must compile but fail behaviorally.
gfortran -std=f2008 -Wall -Wextra -Werror -fcheck=all -Jbuild -Ibuild tests/red_stub.f90 tests/native.f90 -o build/red-native
set +e
build/red-native > evidence/red.log 2>&1
red_exit=$?
set -e
if [[ "$red_exit" -eq 0 ]] || ! grep -q 'FAIL native' evidence/red.log; then echo 'RED did not fail for behavioral reason' >&2; exit 1; fi
echo 'PASS compilable behavioral RED'
rm -f build/spiral_matrix.mod
gfortran -std=f2008 -Wall -Wextra -Werror -fcheck=all -Jbuild -Ibuild src/spiral.f90 tests/native.f90 -o build/native
build/native | tee evidence/green.log
gfortran -std=f2008 -Wall -Wextra -Werror -fcheck=all -Jbuild -Ibuild src/spiral.f90 src/main.f90 -o build/spiral
go test -race tests/oracle.go tests/oracle_test.go | tee evidence/oracle-unit.log
go run tests/oracle.go build/spiral | tee evidence/oracle.log
python3 tests/mutations.py | tee evidence/mutations.log
echo 'PASS complete local suite'
