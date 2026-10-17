# SPDX-License-Identifier: MIT
"""Generator-first Python AST reference for Java tree reconstruction."""
import random,subprocess,sys
rng=random.Random(20261017)
def shape(n):
 if n is None:return '.'
 return str(n[0])+'('+shape(n[1])+')('+shape(n[2])+')'
def pre(n):return [] if n is None else [n[0]]+pre(n[1])+pre(n[2])
def ino(n):return [] if n is None else ino(n[1])+[n[0]]+ino(n[2])
def make(vals):
 if not vals:return None
 i=rng.randrange(len(vals));root=vals[i];rest=vals[:i]+vals[i+1:]
 left=[x for x in rest if rng.random()<.5]
 right=[x for x in rest if x not in left]
 return(root,make(left),make(right))
cases=[];expected=[]
for i in range(900):
 n=rng.randrange(19);vals=rng.sample(range(-100000,100001),n)
 root=make(vals);cases.append((pre(root),ino(root)));expected.append(shape(root))
for case in [([1,1],[1,1]),([1,2],[1,3]),([1,2,3],[3,1,2]),([1,2],[1]),([2],[1])]:
 cases.append(case);expected.append('ERROR')
payload=''.join(','.join(map(str,a))+'|'+','.join(map(str,b))+'\n' for a,b in cases)
p=subprocess.run(['java','-cp',sys.argv[1],'Main'],input=payload,text=True,capture_output=True,check=True,timeout=45)
got=p.stdout.splitlines();assert len(got)==len(cases)
for i,(actual,want) in enumerate(zip(got,expected)):
 assert actual==want,(i,cases[i],want,actual)
print(f'PASS: {len(cases)} independently generated tree reconstructions and invalid cases')
