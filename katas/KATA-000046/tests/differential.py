# SPDX-License-Identifier: MIT
"""Independent 8-direction brute-force reference for seeded grid scenarios."""
import json,random,subprocess,sys
rng=random.Random(20261017)
dirs=[(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1),(-1,-1)]
alpha='ABCDXYZ'
def oracle(g,word):
 h,w=len(g),len(g[0])
 for r in range(h):
  for c in range(w):
   if g[r][c]!=word[0]:continue
   for dr,dc in dirs:
    end=(r+dr*(len(word)-1),c+dc*(len(word)-1))
    if not(0<=end[0]<h and 0<=end[1]<w):continue
    if all(g[r+i*dr][c+i*dc]==ch for i,ch in enumerate(word)):
     return {'word':word,'start':[r,c],'end':list(end)}
 return {'word':word}
cases=[]
for _ in range(400):
 h=rng.randint(1,9);w=rng.randint(1,9)
 grid=[[rng.choice(alpha) for _ in range(w)] for _ in range(h)]
 words=[]
 for _ in range(rng.randint(1,8)):
  if rng.random()<0.55:
   r,c=rng.randrange(h),rng.randrange(w);dr,dc=rng.choice(dirs)
   maximum=1
   while 0<=r+dr*maximum<h and 0<=c+dc*maximum<w:maximum+=1
   n=rng.randint(1,maximum)
   words.append(''.join(grid[r+k*dr][c+k*dc] for k in range(n)))
  else:words.append(''.join(rng.choice(alpha) for _ in range(rng.randint(1,12))))
 cases.append({'grid':[''.join(row) for row in grid],'words':words})
p=subprocess.run([sys.argv[1]],input=json.dumps(cases),capture_output=True,text=True,timeout=50,check=True)
actual=json.loads(p.stdout);assert len(actual)==len(cases)
for index,(case,got) in enumerate(zip(cases,actual)):
 expected=[oracle(case['grid'],word) for word in case['words']]
 assert got==expected,(index,case,expected,got)
print(f'PASS: {len(cases)} independent word-search boards (all eight directions)')
