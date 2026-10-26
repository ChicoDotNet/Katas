#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v swipl >/dev/null || { echo 'BLOCKED: genuine SWI-Prolog runtime missing' >&2; exit 78; }
command -v go >/dev/null || { echo 'BLOCKED: Go runtime missing' >&2; exit 78; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/src" "$TMP/tests"
cp tests/zebra_tests.pl "$TMP/tests/zebra_tests.pl"
cp tests/red_stub.pl "$TMP/src/zebra.pl"
if (cd "$TMP" && swipl -q -s tests/zebra_tests.pl -g run_tests -t halt) >"$TMP/red.log" 2>&1; then
  echo 'ERROR: RED stub unexpectedly passed' >&2; exit 1
fi
echo 'RED: behavioral tests correctly rejected stub'
swipl -q -s tests/zebra_tests.pl -g run_tests -t halt
echo 'GREEN: SWI-Prolog plunit passed'
go test -race tests/oracle.go tests/oracle_test.go
go run tests/oracle.go .
for mutation in reverse_green move_norwegian; do
  cp src/zebra.pl "$TMP/src/zebra.pl"
  if [[ "$mutation" == reverse_green ]]; then
    sed -i 's/Green #= Ivory + 1,/Green #= Ivory - 1,/' "$TMP/src/zebra.pl"
  else
    sed -i 's/Norwegian #= 1,/Norwegian #= 5,/' "$TMP/src/zebra.pl"
  fi
  if (cd "$TMP" && swipl -q -s tests/zebra_tests.pl -g run_tests -t halt) >"$TMP/$mutation.log" 2>&1; then
    echo "ERROR: mutant survived $mutation" >&2; exit 1
  fi
  echo "MUTATION KILLED: $mutation"
done
