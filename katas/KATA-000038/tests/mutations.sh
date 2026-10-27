#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for variant in sign creditor; do
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/src" "$tmp/cmd"; cp go.mod "$tmp/go.mod"; cp src/*.go "$tmp/src/"; cp -r cmd/driver "$tmp/cmd/driver"
  if [[ "$variant" == sign ]]; then
    sed -i 's/if body.Lender != low {/if body.Lender == low {/' "$tmp/src/api.go"
  else
    sed -i 's/if net < 0 {/if net > 0 {/' "$tmp/src/api.go"
  fi
  set +e
  (cd "$tmp" && go test ./src -count=1) > ".build/mutant-${variant}.log" 2>&1
  code=$?
  set -e
  if [[ "$code" == 0 ]]; then echo "SURVIVING NATIVE MUTANT $variant"; rm -rf "$tmp"; exit 1; fi
  (cd "$tmp" && go build -o "$tmp/driver" ./cmd/driver)
  set +e
  ruby tests/oracle.rb "$tmp/driver" > ".build/mutant-${variant}-oracle.log" 2>&1
  oracle_code=$?
  set -e
  rm -rf "$tmp"
  if [[ "$oracle_code" == 0 ]]; then echo "SURVIVING ORACLE MUTANT $variant"; exit 1; fi
  echo "Mutant $variant: detected by native tests AND independent Ruby oracle"
done
