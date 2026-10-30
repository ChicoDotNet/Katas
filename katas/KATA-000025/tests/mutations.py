#!/usr/bin/env python3
"""Mutation orchestrator only: does not calculate oracle answers."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
source = (root / 'src/Calculator.swift').read_text()
mutants = [
    ('threshold-1000', 'if value > 1000 { continue }', 'if value >= 1000 { continue }'),
    ('shortest-delimiter', '$0.count > $1.count', '$0.count < $1.count'),
    ('ignore-negatives', 'if !negatives.isEmpty { throw CalculatorError.negatives(negatives) }',
     'if false && !negatives.isEmpty { throw CalculatorError.negatives(negatives) }'),
]
for name, original, replacement in mutants:
    assert source.count(original) == 1, (name, 'mutation anchor missing or ambiguous')
    with tempfile.TemporaryDirectory() as tmp:
        path = pathlib.Path(tmp) / 'Calculator.swift'
        path.write_text(source.replace(original, replacement))
        exe = pathlib.Path(tmp) / 'native'
        build = subprocess.run(['swiftc', '-swift-version', '6', '-warnings-as-errors', str(path), str(root / 'tests/NativeTests.swift'), '-o', str(exe)], capture_output=True, text=True)
        if build.returncode != 0:
            sys.exit(f'FAIL: {name} did not compile: {build.stderr}')
        run = subprocess.run([str(exe)], capture_output=True, text=True)
        if run.returncode == 0:
            sys.exit(f'FAIL: {name} survived native behavioral suite')
        if 'expected' not in run.stdout + run.stderr:
            sys.exit(f'FAIL: {name} failed for unexpected reason: {run.stderr[:300]}')
        print(f'KILLED {name}: compiled; failed behavioral assertion')
print('3/3 compiled mutants killed')
