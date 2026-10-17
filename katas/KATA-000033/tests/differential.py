# SPDX-License-Identifier: MIT
"""Independent Python token-list reference for a stack language; no source fixture imports."""
import json
import random
import subprocess
import sys
from pathlib import Path

OPS = ('+', '-', '*', '/', 'dup', 'drop', 'swap', 'over')
LIMIT = 9007199254740991

def oracle(program):
    # Definitions capture expanded earlier tokens, not an operation bytecode.
    words = {}
    stack = []
    tokens = program.lower().split()
    index = 0

    def resolved(token):
        if token.startswith('-') and token[1:].isdigit() or token.isdigit():
            value = int(token)
            if abs(value) > LIMIT:
                raise ValueError('invalid')
            return [value]
        if token in words:
            return words[token][:]
        if token in OPS:
            return [token]
        raise ValueError('unknown')

    def apply(word):
        if isinstance(word, int):
            stack.append(word)
            return
        n = 1 if word in ('dup', 'drop') else 2
        if len(stack) < n:
            raise ValueError('underflow')
        if word == 'dup':
            stack.append(stack[-1])
        elif word == 'drop':
            stack.pop()
        elif word == 'over':
            stack.append(stack[-2])
        elif word == 'swap':
            stack[-2:] = stack[-1], stack[-2]
        else:
            b, a = stack.pop(), stack.pop()
            if word == '/' and b == 0:
                raise ValueError('zero')
            if word == '+':
                c = a + b
            elif word == '-':
                c = a - b
            elif word == '*':
                c = a * b
            else:
                c = (abs(a) // abs(b)) * (-1 if (a < 0) != (b < 0) else 1)
            if abs(c) > LIMIT:
                raise ValueError('overflow')
            stack.append(c)

    try:
        while index < len(tokens):
            term = tokens[index]
            index += 1
            if term == ':':
                if index == len(tokens):
                    raise ValueError('invalid')
                name = tokens[index]
                index += 1
                if name in (':', ';') or name.lstrip('-').isdigit():
                    raise ValueError('invalid')
                expansion = []
                while index < len(tokens) and tokens[index] != ';':
                    if tokens[index] == ':':
                        raise ValueError('invalid')
                    expansion.extend(resolved(tokens[index]))
                    index += 1
                if index == len(tokens):
                    raise ValueError('invalid')
                index += 1
                words[name] = expansion
            elif term == ';':
                raise ValueError('invalid')
            else:
                for op in resolved(term):
                    apply(op)
        return {'stack': stack}
    except ValueError as e:
        return {'error': str(e)}

def scenarios():
    randomizer = random.Random(20261017)
    fixed = [
        '', '1 2 3', '1 2 +', ': square dup * ; 12 square',
        ': five 5 ; : ten five five + ; : five 9 ; ten five',
        ': dup 7 ; 5 dup', ': a 3 ; : a a 4 + ; a',
        '5 0 /', '4 2 /', '-7 3 /', '1 swap', ';', ': 3 dup ;',
        ': foo unknown ;', ': foo 4', '1 2 3 swap over',
    ]
    cases = list(fixed)
    atoms = ['-4', '-2', '-1', '0', '1', '2', '3', '4', '5', '6',
             '+', '-', '*', '/', 'dup', 'drop', 'swap', 'over', 'one', 'square', 'missing']
    for _ in range(800):
        prefix = [': one 1 ;', ': square dup * ;']
        if randomizer.random() < .4:
            prefix.append(': swap 3 ;')
        if randomizer.random() < .2:
            prefix.append(': one one 1 + ;')
        series = [randomizer.choice(atoms) for _ in range(randomizer.randrange(0, 34))]
        cases.append(' '.join(prefix + series))
    return cases

cases = scenarios()
result = subprocess.run(['node', str(Path(__file__).resolve().parents[1] / 'cli.js')],
                        input=json.dumps(cases), capture_output=True, text=True,
                        check=True, timeout=25)
outputs = json.loads(result.stdout)
assert len(outputs) == len(cases)
for i, (code, got) in enumerate(zip(cases, outputs)):
    expected = oracle(code)
    assert got == expected, (i, code, expected, got)
print(f'PASS: {len(cases)} independent Forth programs (Python token interpreter vs TypeScript compiled operations)')
