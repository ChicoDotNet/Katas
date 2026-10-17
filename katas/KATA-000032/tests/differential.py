# SPDX-License-Identifier: MIT
"""Independent exhaustive permutation-oracle for small alphametics scenarios."""
import itertools
import json
import random
import subprocess
import sys

DIGITS="0123456789"

def brute(puzzle):
    expression,result=puzzle.split("=")
    words=[s.strip() for s in expression.split("+")]
    target=result.strip()
    symbols=sorted(set("".join(words)+target))
    leading={w[0] for w in (*words,target) if len(w)>1}
    for choice in itertools.permutations(DIGITS,len(symbols)):
        assignment=dict(zip(symbols,choice))
        if any(assignment[c]=="0" for c in leading):continue
        def value(word):return int("".join(assignment[c] for c in word))
        if sum(value(w) for w in words)==value(target):
            return {k:int(v) for k,v in assignment.items()}
    return None

def valid(puzzle,actual):
    if actual is None:return False
    lhs,rhs=puzzle.split("=")
    words=[w.strip() for w in lhs.split("+")]
    target=rhs.strip()
    if set(actual)!=set("".join(words)+target) or len(set(actual.values()))!=len(actual):return False
    if any(type(d) is not int or d not in range(10) for d in actual.values()):return False
    if any(actual[w[0]]==0 for w in (*words,target) if len(w)>1):return False
    def value(word):return int("".join(str(actual[c]) for c in word))
    return sum(value(w) for w in words)==value(target)

rng=random.Random(20261017)
cases=["SEND + MORE = MONEY","I + BB = ILL","AB + AB = AB","A + A = A"]
for _ in range(80):
    alphabet="ABCDE"[:rng.randint(2,4)]
    words=["".join(rng.choices(alphabet,k=rng.randint(1,2))) for _ in range(rng.randint(2,3))]
    result="".join(rng.choices(alphabet,k=rng.randint(1,3)))
    cases.append(" + ".join(words)+" = "+result)
run=subprocess.run([sys.executable,sys.argv[1]],
    input="".join(json.dumps(p)+"\n" for p in cases),
    text=True,capture_output=True,check=True,timeout=60)
results=[json.loads(line) for line in run.stdout.splitlines()]
assert len(results)==len(cases)
for i,(puzzle,actual) in enumerate(zip(cases,results)):
    expected=brute(puzzle)
    assert (actual is None)==(expected is None),(i,puzzle,actual,expected)
    if actual is not None:assert valid(puzzle,actual),(i,puzzle,actual)
print(f"PASS: {len(cases)} independent exhaustive permutation-oracle scenarios")
