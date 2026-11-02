#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v swipl >/dev/null
command -v go >/dev/null
swipl --version
go version
# RED must load and fail on the subtractive behavior, not merely fail to compile.
if swipl -q -g run_tests -t halt -s tests/red_tests.pl > /tmp/ninja-roman-red.log 2>&1; then
  echo 'RED unexpectedly passed' >&2; exit 1
fi
if ! grep -Eq 'test .*: failed|test .*: wrong answer|Assertion failed' /tmp/ninja-roman-red.log; then
  cat /tmp/ninja-roman-red.log; echo 'RED did not fail behaviorally' >&2; exit 1
fi
echo 'RED behavioral failure PASS'
swipl -q -g run_tests -t halt -s tests/green_tests.pl
go vet tests/oracle.go
go run tests/oracle.go
# Three valid syntactic mutations must be detected by independent Go reference.
for mutation in ones4 tens9 hundreds4; do
  tmp="$(mktemp -d)"
  cp src/roman.pl src/cli.pl "$tmp/"
  case "$mutation" in
    ones4) sed -i 's/ones(4) --> "IV"\./ones(4) --> "IIII"./' "$tmp/roman.pl" ;;
    tens9) sed -i 's/tens(9) --> "XC"\./tens(9) --> "LXXXX"./' "$tmp/roman.pl" ;;
    hundreds4) sed -i 's/hundreds(4) --> "CD"\./hundreds(4) --> "CCCC"./' "$tmp/roman.pl" ;;
  esac
  # Load the mutated grammar in the genuine SWI runtime before differential comparison.
  swipl -q -g halt -s "$tmp/roman.pl"
  if go run tests/oracle.go --cli "$tmp/cli.pl" > "$tmp/out" 2>&1; then
    echo "mutant $mutation survived" >&2; rm -rf "$tmp"; exit 1
  fi
  if ! grep -q 'DIFF' "$tmp/out"; then
    cat "$tmp/out"; echo "mutant $mutation failed for wrong reason" >&2; rm -rf "$tmp"; exit 1
  fi
  echo "mutant $mutation detected"
  rm -rf "$tmp"
done
echo 'PASS 3/3 compilable mutations'
