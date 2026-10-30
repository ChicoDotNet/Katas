#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
ruby -c src/tennis.rb
ruby -c src/tennis_red.rb
ruby -c src/cli.rb
ruby -c tests/test_tennis.rb
ruby -c tests/mutations.rb
red_log=$(mktemp)
trap 'rm -f "$red_log"' EXIT
if TENNIS_IMPL=tennis_red ruby -I src tests/test_tennis.rb --seed 27030 > "$red_log" 2>&1; then
  echo 'RED unexpectedly passed' >&2; exit 1
fi
grep -q 'Failure:\|Error:' "$red_log"
echo 'RED Ruby stub parsed and failed behaviorally'
ruby -I src tests/test_tennis.rb --seed 27030
go vet tests/oracle.go
go run tests/oracle.go src/cli.rb
ruby tests/mutations.rb
