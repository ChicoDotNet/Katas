#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
flags=(-std=c++20 -Wall -Wextra -Werror -pedantic -I src)
g++ "${flags[@]}" tests/test_orders.cpp -o "$work/original"
"$work/original"
g++ "${flags[@]}" src/cli.cpp -o "$work/cli"
python3 tests/differential.py "$work/cli"
g++ "${flags[@]}" -DKATA_RED tests/test_orders.cpp -o "$work/red"
if "$work/red" > "$work/red.log" 2>&1; then
  echo 'FAIL: expected behavioral RED passed' >&2
  exit 1
fi
grep -q 'FAIL behavioral invariant' "$work/red.log"
echo 'PASS: original RED failed for intended behavioral reason'
g++ "${flags[@]}" -fsanitize=undefined -fno-sanitize-recover=all tests/test_money_limits.cpp -o "$work/money"
"$work/money"
ruby tests/money_oracle.rb "$work/cli"

mkdir -p "$work/mutant/src" "$work/mutant/tests"
cp tests/test_money_limits.cpp "$work/mutant/tests/test_money_limits.cpp"
for mutation in product total cached; do
  cp src/orders.hpp "$work/mutant/src/orders.hpp"
  python3 - "$work/mutant/src/orders.hpp" "$mutation" <<'PY'
from pathlib import Path
import sys
path, name = Path(sys.argv[1]), sys.argv[2]
source = path.read_text()
changes = {
    'product': ('line.cents<=max/line.quantity', 'true'),
    'total': ('tax_of(next,rate_)<=max-next', 'true'),
    'cached': ('subtotal_=next;', 'subtotal_=0;'),
}
old, new = changes[name]
assert source.count(old) == 1, (name, source.count(old))
path.write_text(source.replace(old, new, 1))
PY
  g++ -std=c++20 -Wall -Wextra -Werror -pedantic -fsanitize=undefined -fno-sanitize-recover=all "$work/mutant/tests/test_money_limits.cpp" -o "$work/mutant-$mutation"
  if "$work/mutant-$mutation" > "$work/mutant-$mutation.log" 2>&1; then
    echo "FAIL: compiled $mutation mutant survived" >&2
    exit 1
  fi
  grep -Eq 'FAIL behavioral invariant|runtime error:' "$work/mutant-$mutation.log"
  echo "PASS: compiled $mutation mutant detected"
done
