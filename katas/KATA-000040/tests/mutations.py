#!/usr/bin/env python3
"""Compile real Swift source mutants; Python orchestrates only, never computes the oracle."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
src = (root / "src/OrderedSet.swift").read_text()
native = root / "tests/native/main.swift"
mutants = [
    ("binary-search-order", "if elements[mid] < value { lo = mid + 1 } else { hi = mid }", "if elements[mid] > value { lo = mid + 1 } else { hi = mid }"),
    ("union-merge-order", "if a < b { result.append(a); i += 1 }\n            else if b < a { result.append(b); j += 1 }", "if a > b { result.append(a); i += 1 }\n            else if b < a { result.append(b); j += 1 }"),
]
with tempfile.TemporaryDirectory(prefix="ninja-set-mutants-") as tmp:
    tmp = Path(tmp)
    for name, old, new in mutants:
        assert src.count(old) == 1, (name, "mutation anchor changed")
        (tmp / "OrderedSet.swift").write_text(src.replace(old, new))
        target = tmp / "mutant"
        subprocess.run(["swiftc", "-O", str(tmp / "OrderedSet.swift"), str(native), "-o", str(target)], check=True, capture_output=True, text=True)
        run = subprocess.run([str(target)], capture_output=True, text=True)
        if run.returncode == 0:
            raise SystemExit(f"MUTANT SURVIVED {name}")
        if "NATIVE FAIL" not in run.stderr:
            raise SystemExit(f"MUTANT DID NOT FAIL BEHAVIORALLY {name}: {run.stderr[-1000:]}")
        print(f"MUTANT KILLED {name}: native behavioral failure")
print("MUTATIONS PASS 2/2")
