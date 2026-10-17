# SPDX-License-Identifier: MIT
"""Independent rule table to check Kotlin inventory transitions."""
import random, subprocess, sys
names = ['Apple','Conjured Cake','Aged Brie','Backstage passes','Sulfuras']
rng = random.Random(20261017)
cases = [(n,s,q) for n in names if n!='Sulfuras' for s in range(-4,17) for q in range(0,51,5)]
cases += [('Sulfuras',s,80) for s in range(-4,17)]
for _ in range(500):
    n = rng.choice(names)
    cases.append((n,rng.randint(-30,60),80 if n=='Sulfuras' else rng.randint(0,50)))
def oracle(name,days,q):
    if name=='Sulfuras':return name,days,q
    if name=='Aged Brie':q=min(50,q+(2 if days<=0 else 1))
    elif name=='Backstage passes':q=0 if days<=0 else min(50,q+(3 if days<=5 else 2 if days<=10 else 1))
    else:q=max(0,q-(2 if name.startswith('Conjured ') else 1)*(2 if days<=0 else 1))
    return name,days-1,q
run=subprocess.run(['java','-jar',sys.argv[1]],input=''.join(f'{n}|{s}|{q}\n' for n,s,q in cases),text=True,capture_output=True,check=True)
got=run.stdout.splitlines()
assert len(got)==len(cases)
for i,(case,result) in enumerate(zip(cases,got)):
    expected='|'.join(map(str,oracle(*case)))
    assert result==expected,(i,case,expected,result)
print(f'PASS: {len(cases)} Kotlin/Python differential inventory transitions')
