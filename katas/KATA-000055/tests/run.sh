#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
cxx=(g++ -std=c++20 -Wall -Wextra -Werror -pedantic -O2)
"${cxx[@]}" -D KATA_RED tests/Native.cpp -o .build/red
if .build/red > .build/red.log 2>&1; then echo 'RED unexpectedly passed';exit 1;fi
grep -q 'FAIL native assertion' .build/red.log
echo 'RED: compilable, fails behaviorally PASS'
"${cxx[@]}" tests/Native.cpp -o .build/native
.build/native
"${cxx[@]}" src/Main.cpp -o .build/cli
go test -race tests/oracle.go tests/oracle_test.go
go run tests/oracle.go "$(pwd)/.build/cli"
for mutation in KATA_MUTANT_DUP_RIGHT KATA_MUTANT_DROP_NEGATIVE;do
 "${cxx[@]}" -D "$mutation" tests/Native.cpp -o .build/mutant
 if .build/mutant > .build/mutant.log 2>&1;then echo "surviving mutant $mutation";exit 1;fi
 grep -q 'FAIL native assertion' .build/mutant.log
 echo "Mutant $mutation detected"
done
echo 'KATA-000055 suite PASS'
