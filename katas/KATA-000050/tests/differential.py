# SPDX-License-Identifier: MIT
"""Independent combination oracle, without bit-mask search."""
import itertools,random,subprocess,sys
rng=random.Random(20261017)
cases=[(n,s,mask) for n in range(1,10) for s in range(1,46) for mask in (0,1,9,128,511)]
cases.extend((rng.randint(1,9),rng.randint(1,45),rng.randint(0,511)) for _ in range(500))
def oracle(n,target,mask):
 banned={d for d in range(1,10) if mask&(1<<(d-1))}
 return sorted(int(''.join(map(str,c))) for c in itertools.combinations(range(1,10),n) if sum(c)==target and not any(x in banned for x in c))
p=subprocess.run([sys.argv[1]],input=''.join(f'{n},{s},{m}\n' for n,s,m in cases),text=True,capture_output=True,check=True,timeout=30)
rows=p.stdout.splitlines();assert len(rows)==len(cases)
for i,((n,s,m),line) in enumerate(zip(cases,rows)):
 a,sep,b=line.partition('|');assert sep
 got=[int(x) for x in b.split(',')] if b else []
 want=oracle(n,s,m)
 assert int(a)==len(got) and got==want,(i,(n,s,m),want,got)
print(f'PASS: {len(cases)} independent Killer Sudoku cage combinations')
