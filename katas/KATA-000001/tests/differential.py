# SPDX-License-Identifier: MIT
"""Independent behavioral oracle for ORIGINAL game contract, no GPL implementation."""
import random
import subprocess
import sys
from pathlib import Path

CLASS_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('/tmp/ninja-trivia-green')
TOPICS = ('LOGIC', 'NATURE', 'HISTORY', 'ARTS')


def oracle(names, moves):
    # Separate Python dict-based state machine, not a Java transcription.
    people = {name: {'station': 0, 'points': 0, 'paused': False} for name in names}
    question_counter = dict.fromkeys(TOPICS, 0)
    output = [f'WELCOME {name}' for name in names]
    for index, (roll, correct) in enumerate(moves):
        name = names[index % len(names)]
        state = people[name]
        output.append(f'TURN {name} roll={roll}')
        if state['paused']:
            if roll % 2:
                output.append(f'SKIP {name}')
                continue
            output.append(f'RETURN {name}')
            state['paused'] = False
        state['station'] = (state['station'] + roll) % 12
        output.append(f'MOVE {name} {state["station"]}')
        category = TOPICS[state['station'] % len(TOPICS)]
        question_counter[category] += 1
        output.append(f'ASK {category}#{question_counter[category]}')
        if correct:
            state['points'] += 1
            output.append(f'RIGHT {name} score={state["points"]}')
            if state['points'] >= 5:
                output.append(f'WIN {name}')
                break
        else:
            state['paused'] = True
            output.append(f'WRONG {name}')
    else:
        output.append('NO_WINNER')
    return '\n'.join(output) + '\n'


def run_java(mode, names, moves):
    script = 'PLAYERS ' + ','.join(names) + '\n'
    script += ''.join(f'{roll} {"C" if correct else "W"}\n' for roll, correct in moves)
    p = subprocess.run(
        ['java', '-cp', str(CLASS_DIR), 'TriviaCli', mode],
        input=script, capture_output=True, text=True, check=True, timeout=10
    )
    return p.stdout


def check(names, moves):
    expected = oracle(names, moves)
    for mode in ('legacy', 'refactored'):
        actual = run_java(mode, names, moves)
        assert actual == expected, (mode, names, moves, expected, actual)


cases = [
    (['Ada', 'Bea'], []),
    (['Ada', 'Bea'], [(1, False)] * 30),
    (['Ada', 'Bea'], [(2, True)] * 30),
    (['Ada', 'Bea', 'Cy'], [(6, False), (1, False), (2, True)] * 12),
]
rng = random.Random(20261017)
for _ in range(192):
    n = rng.randint(2, 6)
    names = ['P' + str(i) for i in range(n)]
    moves = [(rng.randint(1, 6), bool(rng.getrandbits(1))) for _ in range(rng.randrange(0, 100))]
    cases.append((names, moves))
for names, moves in cases:
    check(names, moves)

for script in (
    'PLAYERS Ada,Ada\n1 C\n',
    'PLAYERS Ada\n1 C\n',
    'PLAYERS Ada,Bea\n0 C\n',
    'PLAYERS Ada,Bea\n7 W\n',
    'PLAYERS Ada,Bea\n1 Z\n',
):
    p = subprocess.run(['java', '-cp', str(CLASS_DIR), 'TriviaCli', 'refactored'],
                       input=script, capture_output=True, text=True, timeout=10)
    assert p.returncode != 0, script
print(f'PASS: {len(cases)} independent scripted scenarios x 2 implementations + 5 invalid inputs')
