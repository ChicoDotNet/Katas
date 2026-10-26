#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Perl: $(perl -e 'printf "%vd", $^V')"; echo "Go: $(go version)"
perl -c tests/red_stub.pl
set +e
KATA_GREP_IMPL=tests/red_stub.pl perl tests/native.t > evidence/red.log 2>&1
red_status=$?
set -e
if [[ "$red_status" -eq 0 ]] || ! grep -q '^not ok' evidence/red.log; then echo 'RED did not fail behaviorally' >&2; exit 1; fi
echo "RED native tests failed behaviorally as expected (exit $red_status)"
perl -c src/grep.pl
perl tests/native.t | tee evidence/green.log
go vet tests/oracle.go tests/oracle_test.go
go test -race tests/oracle.go tests/oracle_test.go | tee evidence/oracle-unit.log
mkdir -p build
go build -o build/grep-oracle tests/oracle.go
build/grep-oracle | tee evidence/oracle.log
python3 tests/mutations.py | tee evidence/mutations.log
echo 'PASS full local suite'
