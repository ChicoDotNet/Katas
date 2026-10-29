#!/usr/bin/env bash
# Strict CLI framing: reject undeclared records and excess fields.
set -euo pipefail
binary="${1:?usage: cli_contract.sh /path/to/lights-cli}"
expect_reject() {
  local input="$1" label="$2"
  if printf '%s' "$input" | "$binary" > /dev/null 2>&1; then
    echo "FAIL CLI accepted $label" >&2
    exit 1
  fi
}
expected="$(printf '2 1\n1 0 0 1 1\n\n' | "$binary")"
[[ "$expected" == '4 4' ]] || { echo "FAIL valid CLI: $expected" >&2; exit 1; }
expect_reject $'2 0\n1 0 0 1 1\n' 'undeclared command'
expect_reject $'2 1\n1 0 0 1 1\n3 0 0 1 1\n' 'second undeclared command'
expect_reject $'2 0 EXTRA\n' 'extra header field'
expect_reject $'2 1\n1 0 0 1 1 EXTRA\n' 'extra command field'
expect_reject $'2 1\n1 0 0 1 1\nGARBAGE\n' 'trailing garbage'
expect_reject $'2 1\n' 'missing command'
expect_reject $'2 1\n1 0 0 1\n' 'incomplete command'
expect_reject $'2 1\n1 0 0 2 1\n' 'out-of-bounds rectangle'
echo 'CLI CONTRACT PASS: 1 accepted, 8 rejected'
