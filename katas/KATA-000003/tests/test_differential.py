# SPDX-License-Identifier: MIT
"""Independent Python neighbor-set oracle (not a translation of Fortran loops)."""
import itertools
import random
import subprocess
import sys
from pathlib import Path

BIN = Path(sys.argv[1] if len(sys.argv) > 1 else '/tmp/ninja-life-cli')


def oracle(rows):
    height = len(rows)
    width = len(rows[0]) if rows else 0
    alive = {(r, c) for r in range(height) for c in range(width) if rows[r][c] == '1'}
    counts = {}
    for r, c in alive:
        for dr, dc in itertools.product((-1, 0, 1), repeat=2):
            if dr == dc == 0:
                continue
            neighbor = r + dr, c + dc
            if 0 <= neighbor[0] < height and 0 <= neighbor[1] < width:
                counts[neighbor] = counts.get(neighbor, 0) + 1
    next_alive = {cell for cell, n in counts.items() if n == 3 or (cell in alive and n == 2)}
    return [''.join('1' if (r, c) in next_alive else '0' for c in range(width)) for r in range(height)]


def check(rows):
    columns = len(rows[0]) if rows else 0
    payload = f'{len(rows)} {columns}\n' + '\n'.join(rows) + '\n'
    result = subprocess.run([str(BIN)], input=payload, text=True, capture_output=True, check=True)
    actual = result.stdout.splitlines()
    expected = oracle(rows)
    assert actual == expected, (rows, expected, actual)


for h, w in ((1, 1), (2, 3), (3, 3)):
    for cells in itertools.product('01', repeat=h * w):
        rows = [''.join(cells[y*w:(y+1)*w]) for y in range(h)]
        check(rows)

rng = random.Random(20261017)
for _ in range(100):
    h, w = 4, 6
    rows = [''.join(rng.choices('01', k=w)) for _ in range(h)]
    check(rows)
print('PASS: 1+64+512 exhaustive boards + 100 seeded 4x6 differential boards')
