#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
perl -I src -c src/Ohce.pm
perl -I src -c src/OhceRed.pm
perl -I src -c src/ohce.pl
perl -I src -c tests/native.t
red=$(mktemp)
trap 'rm -f "$red"' EXIT
if OHCE_IMPL=OhceRed perl -I src tests/native.t > "$red" 2>&1; then echo 'RED unexpectedly passed' >&2; exit 1; fi
grep -q 'not ok' "$red"
echo 'RED parseable and behaviorally failed'
perl -I src tests/native.t
ruby -c tests/oracle.rb
ruby tests/oracle.rb
ruby tests/mutations.rb
