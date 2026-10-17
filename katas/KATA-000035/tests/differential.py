# SPDX-License-Identifier: MIT
"""Independent subset-enumeration oracle against Fortran descending-capacity DP."""
import random
import subprocess
import sys

rng = random.Random(20261017)
cases = [(10, [(5,10),(4,40),(6,30),(4,50)]), (0, [(0,3),(0,4)])]
for _ in range(498):
    items = [(rng.randint(0,25),rng.randint(0,1000)) for _ in range(rng.randint(0,12))]
    cases.append((rng.randint(0,65),items))

def exhaustive(cap, items):
    best = 0
    for mask in range(1 << len(items)):
        chosen = [items[i] for i in range(len(items)) if (mask >> i) & 1]
        if sum(weight for weight, _ in chosen) <= cap:
            best = max(best, sum(value for _, value in chosen))
    return best

lines = [str(len(cases))]
for cap, items in cases:
    lines.append(f'{cap} {len(items)}')
    lines.extend(f'{w} {v}' for w,v in items)
result = subprocess.run([sys.argv[1]],input='\n'.join(lines)+'\n',text=True,capture_output=True,check=True,timeout=30)
actual = result.stdout.splitlines()
assert len(actual) == len(cases), (len(actual),len(cases))
for i, (case, got) in enumerate(zip(cases,actual)):
    expected = exhaustive(*case)
    assert int(got) == expected, (i,case,expected,got)
print(f'PASS: {len(cases)} independent exhaustive 0-1 knapsack scenarios')
