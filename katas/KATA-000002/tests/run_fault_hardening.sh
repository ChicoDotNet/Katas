#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
php -l src/Bank.php
php -l tests/fault_injection.php
php tests/fault_injection.php
python3 tests/differential.py
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
for mutant in invalid-before-clock double-clock no-overflow; do
  python3 - "$mutant" "src/Bank.php" "$workdir/Bank.php" <<'PY'
from pathlib import Path
import sys
name, original, destination = sys.argv[1:]
source = Path(original).read_text()
replacements = {
    'invalid-before-clock': (
        'self::requirePositive($amount);\n        $this->ledger->append($this->clock->today(), $amount);',
        '$this->ledger->append($this->clock->today(), $amount);\n        self::requirePositive($amount);',
    ),
    'double-clock': (
        'self::requirePositive($amount);\n        $this->ledger->append($this->clock->today(), $amount);',
        'self::requirePositive($amount);\n        $this->clock->today();\n        $this->ledger->append($this->clock->today(), $amount);',
    ),
    'no-overflow': (
        'if ($signedAmount > 0 && $previous > PHP_INT_MAX - $signedAmount) {',
        'if (false) {',
    ),
}
old, new = replacements[name]
if source.count(old) != 1:
    raise SystemExit(f'mutation {name} anchor count != 1')
Path(destination).write_text(source.replace(old, new))
PY
  php -l "$workdir/Bank.php" >/dev/null
  if BANK_IMPL="$workdir/Bank.php" php tests/fault_injection.php >"$workdir/$mutant.log" 2>&1; then
    echo "FAIL: compiled mutant $mutant survived" >&2
    exit 1
  fi
  if ! grep -Eq 'FAIL:|exception type:' "$workdir/$mutant.log"; then
    echo "FAIL: mutant $mutant failed without a controlled assertion" >&2
    cat "$workdir/$mutant.log" >&2
    exit 1
  fi
  echo "PASS: compiled mutant $mutant detected: $(grep -E 'FAIL:' "$workdir/$mutant.log" | head -1)"
done
