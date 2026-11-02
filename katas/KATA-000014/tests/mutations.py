#!/usr/bin/env python3
"""Mutation orchestrator only: Go owns expected results and checks real Swift binaries."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/Wardrobe.swift').read_text()
mutants = [
    ('wrong-price-75', 'static let prices = [59, 62, 90, 111]', 'static let prices = [59, 63, 90, 111]'),
    ('wrong-width-120', 'static let widths = [50, 75, 100, 120]', 'static let widths = [50, 75, 100, 121]'),
    ('accept-incomplete-plan', 'return remaining == 0 ? [[]] : []', 'return remaining >= 0 ? [[]] : []'),
]
with tempfile.TemporaryDirectory(prefix='ninja-wardrobe-mutations-') as tmp:
    directory = Path(tmp)
    oracle = directory / 'oracle'
    subprocess.run(['go', 'build', '-o', str(oracle), 'tests/oracle.go'], cwd=root, check=True, capture_output=True, text=True)
    for name, before, after in mutants:
        if source.count(before) != 1:
            raise RuntimeError(f'unsafe mutation pattern for {name}')
        mutant = directory / 'Wardrobe.swift'
        mutant.write_text(source.replace(before, after))
        binary = directory / name
        compile_result = subprocess.run(['swiftc', '-swift-version', '6', '-warnings-as-errors', str(mutant), str(root / 'src/main.swift'), '-o', str(binary)], cwd=root, capture_output=True, text=True, timeout=45)
        if compile_result.returncode:
            raise RuntimeError(f'{name} did not compile: {compile_result.stderr}')
        test = subprocess.run([str(oracle), str(binary)], cwd=root, capture_output=True, text=True, timeout=45)
        if test.returncode == 0 or "EXPECTED:" not in test.stderr:
            raise RuntimeError(f'{name} not behaviorally detected: code={test.returncode} stderr={test.stderr[:200]!r}')
        print(f'MUTANT {name}: compiled; independent Go oracle rejected behavioral mismatch')
print(f'{len(mutants)}/{len(mutants)} compiled Swift mutants behaviorally killed')
