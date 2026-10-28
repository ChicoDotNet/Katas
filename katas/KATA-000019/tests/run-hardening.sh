#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP"/{legacy,new,mutant-alias,mutant-partial}
# The client is compiled solely against a legacy API shell, never the new source.
javac --release 21 -d "$TMP/legacy" tests/legacy-api/ShoppingCart.java tests/LegacyConsumer.java
# Production compiled separately; first classpath entry overrides the old shell.
javac --release 21 -d "$TMP/new" src/ShoppingCart.java tests/TestCartContracts.java
java -cp "$TMP/new:$TMP/legacy" LegacyConsumer
java -cp "$TMP/new" TestCartContracts
# Mutation A: return a live mutable alias rather than an immutable snapshot.
sed 's/return List.copyOf(items);/return items;/' src/ShoppingCart.java > "$TMP/mutant-alias/ShoppingCart.java"
javac --release 21 -d "$TMP/mutant-alias" "$TMP/mutant-alias/ShoppingCart.java" tests/TestCartContracts.java
if java -cp "$TMP/mutant-alias" TestCartContracts >"$TMP/alias.log" 2>&1; then
  echo 'ERROR: alias mutant survived' >&2; exit 1
fi
grep -Eq 'snapshot is writable|snapshot after append|historical snapshot isolation' "$TMP/alias.log"
echo 'PASS: mutable alias mutant killed'
# Mutation B: prematurely commit a partial list before rejecting a null element.
sed 's/if(value==null) throw new IllegalArgumentException("null item");/if(value==null) { items=copy; throw new IllegalArgumentException("null item"); }/' src/ShoppingCart.java > "$TMP/mutant-partial/ShoppingCart.java"
javac --release 21 -d "$TMP/mutant-partial" "$TMP/mutant-partial/ShoppingCart.java" tests/TestCartContracts.java
if java -cp "$TMP/mutant-partial" TestCartContracts >"$TMP/partial.log" 2>&1; then
  echo 'ERROR: partial mutation survived' >&2; exit 1
fi
grep -Eq 'atomic null rejection|atomic negative rejection|random atomic rollback' "$TMP/partial.log"
echo 'PASS: partial-commit mutant killed'
