#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

kotlinc src/Inventory.kt tests/TrajectoryTest.kt -include-runtime -d "$work/trajectory-test.jar"
java -jar "$work/trajectory-test.jar"
kotlinc src/Inventory.kt src/TrajectoryCli.kt -include-runtime -d "$work/trajectory-cli.jar"
ruby tests/trajectory_oracle.rb "$work/trajectory-cli.jar"

# Mutation only at day -31: outside the previous single-day oracle's [-30,60]
# random and [-4,16] grid. This should be detected by the new long trajectories.
ruby -e '
  s = File.read(ARGV.fetch(0))
  old = %q{item.name == "Aged Brie" -> if (days <= 0) 2 else 1}
  replacement = %q{item.name == "Aged Brie" -> if (days == -31) 1 else if (days <= 0) 2 else 1}
  abort("mutation target not unique") unless s.scan(old).length == 1
  File.write(ARGV.fetch(1), s.sub(old, replacement))
' src/Inventory.kt "$work/InventoryMutant.kt"
kotlinc "$work/InventoryMutant.kt" src/TrajectoryCli.kt -include-runtime -d "$work/trajectory-mutant.jar"
if ruby tests/trajectory_oracle.rb "$work/trajectory-mutant.jar" >"$work/mutant.log" 2>&1; then
  echo 'FAIL: temporal mutant survived independent oracle' >&2
  exit 1
fi
grep -q 'DIFFERENTIAL FAIL' "$work/mutant.log"
echo 'PASS: 1/1 long-horizon temporal mutants detected (Brie day -31)'
