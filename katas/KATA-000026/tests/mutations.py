#!/usr/bin/env python3
"""Compile mutated Kotlin code; no reference values computed in Python."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/TaskBook.kt').read_text()
mutants = [
    ('sequence-reuse', 'nextSequence++', 'tasks.size'),
    ('include-done-today', '!it.done && it.deadline == date', 'it.deadline == date'),
    ('include-undated', 'tasks.values.filter { it.deadline != null }', 'tasks.values.filter { true }'),
]
for name, before, after in mutants:
    assert source.count(before) == 1, (name, 'anchor')
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / 'TaskBook.kt'
        path.write_text(source.replace(before, after))
        jar = Path(tmp) / 'native.jar'
        build = subprocess.run(['kotlinc', str(path), str(root/'tests/NativeTests.kt'), '-include-runtime', '-d', str(jar)], capture_output=True, text=True)
        assert build.returncode == 0, f'{name} did not compile: {build.stderr}'
        run = subprocess.run(['java', '-cp', str(jar), 'NativeTests'], capture_output=True, text=True)
        assert run.returncode != 0 and 'behavior expected=' in run.stderr, f'{name} survived or failed incorrectly: {run.stderr}'
        print('KILLED', name, 'compiled and behaviorally rejected')
print('3/3 compiled Kotlin mutants killed')
