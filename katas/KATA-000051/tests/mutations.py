#!/usr/bin/env python3
"""Orchestration only; semantic tests run in authentic Fortran and Go runtimes."""
import pathlib
import subprocess
import tempfile

root = pathlib.Path(__file__).resolve().parent.parent
source = (root / "src/spiral.f90").read_text()
mutants = {
    "reverse_top_edge": ("do col = left, right", "do col = right, left, -1"),
    "skip_right_column": ("do row = top, bottom", "do row = top, bottom, 2"),
    "wrong_inner_right_boundary": ("right = right - 1", "right = right - 2"),
    "wrong_value_increment": ("value = value + 1_int64", "value = value + 2_int64"),
    "skip_left_column": ("do row = bottom, top, -1", "do row = bottom, top, -2"),
}
for label, (before, after) in mutants.items():
    if source.count(before) != 1 and label != "wrong_value_increment":
        raise RuntimeError(f"ambiguous mutation {label}: {source.count(before)}")
    if before not in source:
        raise RuntimeError(f"mutation anchor missing: {label}")
    with tempfile.TemporaryDirectory(prefix="ninja-spiral-mutation-") as td:
        t = pathlib.Path(td)
        (t / "mutant.f90").write_text(source.replace(before, after, 1))
        exe = t / "native"
        compile_result = subprocess.run(
            ["gfortran", "-std=f2008", "-fcheck=all", "-J", td, "-I", td,
             str(t / "mutant.f90"), str(root / "tests/native.f90"), "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if compile_result.returncode:
            raise RuntimeError(f"{label} not compilable: {compile_result.stderr}")
        test = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
        if test.returncode == 0 or "FAIL native" not in test.stdout:
            raise RuntimeError(f"{label} escaped native tests: {test.stdout} {test.stderr}")
        print(f"KILLED {label}: Fortran native behavioral rejection")
print(f"PASS {len(mutants)} compilable Fortran mutants killed")
