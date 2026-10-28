#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
CXX="${CXX:-g++}"
"$CXX" --version | head -1
ruby --version
"$CXX" -std=c++20 -O1 -Wall -Wextra -Werror tests/red.cpp -o "$TMP/red"
if "$TMP/red" >"$TMP/red.log" 2>&1; then echo 'RED unexpectedly passed'; exit 1; fi
grep -q 'EXPECTED RED: missing formatted entry' "$TMP/red.log"
cat "$TMP/red.log" | tee evidence/red.log
"$CXX" -std=c++20 -O1 -g -Wall -Wextra -Werror -fsanitize=address,undefined -fno-omit-frame-pointer tests/native.cpp -o "$TMP/native"
"$TMP/native" | tee evidence/green.log
"$CXX" -std=c++20 -O2 -Wall -Wextra -Werror src/main.cpp -o "$TMP/ledger"
ruby tests/oracle.rb "$TMP/ledger" | tee evidence/oracle.log
python3 tests/mutations.py | tee evidence/mutations.log
printf 'PASS FULL SUITE\n'
