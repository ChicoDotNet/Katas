#!/usr/bin/env python3
"""Compiles real Java mutants; requires behavioral oracle disagreement."""
import pathlib
import subprocess
import sys
import tempfile

kata = pathlib.Path(__file__).resolve().parents[1]
original = (kata / 'src/TicTacToe.java').read_text(encoding='utf-8')
mutants = {
    'accept-impossible-turn-counts': (
        'if (!(x == o || x == o + 1)) return "ERR:unreachable";',
        'if (false) return "ERR:unreachable";',
    ),
    'accept-impossible-winners': (
        'if ((xWon && oWon) || (xWon && x != o + 1) || (oWon && x != o)) {',
        'if (false) {',
    ),
    'misclassify-terminal-winner': (
        'if (xWon) return "WIN:X";',
        'if (xWon) return "NEXT:O|MOVES:";',
    ),
}
for name, (before, after) in mutants.items():
    if original.count(before) != 1:
        raise SystemExit(f'{name}: mutation anchor not unique')
    with tempfile.TemporaryDirectory(prefix='ninja-tictactoe-mutant-') as tmp:
        tmp = pathlib.Path(tmp)
        (tmp / 'TicTacToe.java').write_text(original.replace(before, after), encoding='utf-8')
        compile_result = subprocess.run(
            ['javac', '--release', '21', '-d', str(tmp), str(tmp / 'TicTacToe.java'), str(kata / 'src/Main.java')],
            capture_output=True, text=True, timeout=30,
        )
        if compile_result.returncode:
            raise SystemExit(f'{name}: invalid mutant (compilation failed): {compile_result.stderr}')
        oracle = subprocess.run(
            ['go', 'run', str(kata / 'tests/oracle.go'), str(tmp)],
            capture_output=True, text=True, timeout=45,
        )
        if oracle.returncode == 0 or 'differential #' not in oracle.stderr:
            raise SystemExit(f'{name}: no behavioral oracle disagreement: {oracle.stderr[:300]}')
        print(f'MUTANT {name}: compiled, behaviorally rejected')
print('3/3 compiled Java mutants killed')
