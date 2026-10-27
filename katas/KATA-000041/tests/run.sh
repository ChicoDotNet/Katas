#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cxx=(g++ -std=c++20 -O1 -g -Wall -Wextra -Werror -pedantic -fsanitize=address,undefined -fno-omit-frame-pointer)
"${cxx[@]}" -DKATA_RED tests/native/main.cpp -o "$work/red"
if "$work/red" >evidence/red.txt 2>&1; then echo 'RED DID NOT FAIL' >&2; exit 1; fi
grep -q 'NATIVE FAIL' evidence/red.txt || { echo 'RED failure not behavioral' >&2; exit 1; }
echo 'RED compiled and failed behaviorally'
"${cxx[@]}" tests/native/main.cpp -o "$work/native"
"$work/native" | tee evidence/green.txt
"${cxx[@]}" src/main.cpp -o "$work/driver"
LIST_DRIVER="$work/driver" ruby tests/oracle/oracle.rb | tee evidence/oracle.txt
for mutant in KATA_MUTANT_ERASE_LAST KATA_MUTANT_POP_BACK_FRONT; do
  "${cxx[@]}" -D"$mutant" tests/native/main.cpp -o "$work/mutant"
  if "$work/mutant" >"$work/$mutant.log" 2>&1; then echo "MUTANT SURVIVED $mutant" >&2; exit 1; fi
  grep -q 'NATIVE FAIL' "$work/$mutant.log" || { echo "MUTANT FAILURE NOT BEHAVIORAL $mutant" >&2; exit 1; }
  printf 'MUTANT KILLED %s: native behavioral failure\n' "$mutant"
done | tee evidence/mutations.txt
printf 'MUTATIONS PASS 2/2\n'
printf 'FULL SUITE PASS\n'
