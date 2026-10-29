#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
(
 cd "$tmp"
 gfortran -std=f2008 -Wall -Wextra -fcheck=all "$OLDPWD/tests/lights_red_stub.f90" "$OLDPWD/tests/test_lights.f90" -o red
 if ./red >red.log 2>&1; then echo 'RED incorrectly passed'; exit 1; fi
 grep -q 'FAIL totals expected' red.log || { cat red.log; echo 'RED did not fail by behavior'; exit 1; }
 echo 'RED PASS (compiles, fails on expected behavioral invariant)'
 gfortran -std=f2008 -Wall -Wextra -fcheck=all "$OLDPWD/src/lights.f90" "$OLDPWD/tests/test_lights.f90" -o green
 ./green
 gfortran -std=f2008 -Wall -Wextra -fcheck=all "$OLDPWD/src/lights.f90" "$OLDPWD/src/lights_cli.f90" -o cli
 go build -o oracle "$OLDPWD/tests/oracle.go"
 go vet "$OLDPWD/tests/oracle.go"
 ./oracle ./cli
 for mutant in toggle off inclusive; do
   python3 "$OLDPWD/tests/mutations.py" "$OLDPWD/src/lights.f90" "$mutant" "$tmp/mutant.f90"
   gfortran -std=f2008 -Wall -Wextra -fcheck=all "$tmp/mutant.f90" "$OLDPWD/src/lights_cli.f90" -o mutant-cli
   if ./oracle ./mutant-cli --quick >"$tmp/$mutant.log" 2>&1; then
      echo "UNDETECTED MUTANT $mutant"; exit 1
   fi
   grep -q 'ORACLE FAIL' "$tmp/$mutant.log" || { cat "$tmp/$mutant.log"; exit 1; }
   echo "MUTANT DETECTED $mutant"
 done
)
