#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ruby tests/red.rb > /tmp/ninja-trip-red-$$.log 2>&1; then
  echo 'RED unexpectedly passed'; exit 1
fi
if ! grep -q '1 failures' /tmp/ninja-trip-red-$$.log; then
  cat /tmp/ninja-trip-red-$$.log; echo 'RED failed for unexpected reason'; exit 1
fi
rm -f /tmp/ninja-trip-red-$$.log
echo 'RED behavioral failure confirmed'
ruby tests/native_test.rb
go vet tests/oracle.go
go run tests/oracle.go src/cli.rb
ruby tests/mutations.rb
