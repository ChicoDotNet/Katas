#!/usr/bin/env python3
"""Compile each genuine Fortran mutant; Python only orchestrates, never models."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/flower_field.f90').read_text()
mutations = {
    'exclude-upper-left': ('row-1:row+1, col-1:col+1', 'row:row+1, col-1:col+1'),
    'ignore-right-column': ('row-1:row+1, col-1:col+1', 'row-1:row+1, col-1:col'),
    'erase-zero': ("marked(row, col) = '.'", "marked(row, col) = '0'"),
}
for name, (before, after) in mutations.items():
    assert source.count(before) == 1, (name, 'mutation anchor changed')
    with tempfile.TemporaryDirectory(prefix='flower-mutant-') as d:
        d = Path(d)
        (d / 'mutant.f90').write_text(source.replace(before, after))
        subprocess.run(['gfortran','-std=f2008','-fcheck=all','-J',str(d),
                        '-o',str(d/'native'),str(d/'mutant.f90'),str(root/'tests/native.f90')],
                       check=True, capture_output=True)
        result = subprocess.run([str(d/'native')], capture_output=True, text=True)
        if result.returncode == 0:
            raise SystemExit(f'FAIL surviving compiled mutant: {name}')
        if 'FAIL native:' not in result.stdout:
            raise SystemExit(f'FAIL mutant did not fail behaviorally: {name}: {result.stdout} {result.stderr}')
        print(f'PASS compiled mutant killed: {name}')
