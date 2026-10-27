#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build evidence
rm -f build/*.o build/*.mod build/native build/red build/flower-field
flags=(-std=f2008 -Wall -Wextra -fcheck=all -fbacktrace)
# A genuine, compilable behavioral RED is required, not a missing symbol.
gfortran "${flags[@]}" -J build -o build/red tests/red/flower_field.f90 tests/native.f90
if build/red > evidence/red.txt 2>&1; then
  echo 'FAIL: RED unexpectedly passed'; exit 1
fi
grep -q 'FAIL native:' evidence/red.txt || { cat evidence/red.txt; echo 'FAIL: wrong RED reason'; exit 1; }
echo 'PASS genuine behavioral RED'
gfortran "${flags[@]}" -J build -o build/native src/flower_field.f90 tests/native.f90
build/native | tee evidence/green.txt
gfortran "${flags[@]}" -J build -o build/flower-field src/flower_field.f90 src/driver.f90
(cd tests/oracle && go test -race -timeout 90s -count=1 -v ./...) > evidence/oracle.txt 2>&1
cat evidence/oracle.txt
python3 tests/mutations.py > evidence/mutations.txt 2>&1
cat evidence/mutations.txt
echo 'PASS full Fortran/Go suite'
