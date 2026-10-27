#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
CXX=${CXX:-g++}
FLAGS=(-std=c++20 -O1 -g -Wall -Wextra -Wpedantic -Werror -fno-omit-frame-pointer)
"$CXX" "${FLAGS[@]}" -DRED_STUB tests/native/test.cpp -o .build/red
if .build/red > .build/red.log 2>&1; then
  echo 'RED unexpectedly passed' >&2; exit 1
fi
echo 'RED_PASS compiled stub fails native behavioral assertions'
"$CXX" "${FLAGS[@]}" -fsanitize=address,undefined tests/native/test.cpp -o .build/native
ASAN_OPTIONS=detect_leaks=1 .build/native
"$CXX" "${FLAGS[@]}" -fsanitize=address,undefined src/main.cpp -o .build/microblog
ruby tests/oracle/oracle.rb .build/microblog
for mutation in MUTANT_OFF_BY_ONE MUTANT_ACCEPT_OVERLONG; do
  "$CXX" "${FLAGS[@]}" -D"$mutation" src/main.cpp -o .build/mutant
  if ruby tests/oracle/oracle.rb .build/mutant > .build/mutant.log 2>&1; then
    echo "MUTANT SURVIVED: $mutation" >&2; exit 1
  fi
  echo "MUTANT_KILLED $mutation"
done
echo 'FULL_SUITE_PASS'
