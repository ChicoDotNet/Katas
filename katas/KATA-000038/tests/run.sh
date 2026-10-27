#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build evidence
set +e
go test ./tests/red -count=1 > .build/red.log 2>&1
red_code=$?
set -e
if [[ "$red_code" == 0 ]] || ! grep -q 'behavioral RED: GET /users returned 501; expected 200' .build/red.log; then
  echo 'RED did not fail for the intended behavior'; cat .build/red.log; exit 1
fi
echo 'RED compiled and failed behaviorally as expected'
go vet ./src ./cmd/driver
go test -race -count=1 ./src
go build -o .build/driver ./cmd/driver
ruby tests/oracle.rb "$(pwd)/.build/driver"
bash tests/mutations.sh
echo 'FULL SUITE PASS'
