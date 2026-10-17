# SPDX-License-Identifier: MIT
"""Independent Python union-find oracle for C++ Hex BFS."""
import random,subprocess,sys
rng=random.Random(20261017)
OFFSETS=[(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0)]
def oracle(board):
 h,w=len(board),len(board[0])
 for who in ('O','X'):
  size=h*w+2;start=h*w;target=start+1
  parent=list(range(size))
  def find(a):
   while a!=parent[a]:
    parent[a]=parent[parent[a]];a=parent[a]
   return a
  def union(a,b):parent[find(a)]=find(b)
  for r in range(h):
   for c in range(w):
    if board[r][c]!=who:continue
    pos=r*w+c
    if (who=='O' and r==0) or (who=='X' and c==0):union(pos,start)
    if (who=='O' and r==h-1) or (who=='X' and c==w-1):union(pos,target)
    for dr,dc in OFFSETS:
     nr,nc=r+dr,c+dc
     if 0<=nr<h and 0<=nc<w and board[nr][nc]==who:union(pos,nr*w+nc)
  if find(start)==find(target):return who
 return '.'
cases=[]
for h in range(1,7):
 for w in range(1,7):
  for _ in range(25):cases.append([''.join(rng.choices('..OOXX',k=w)) for i in range(h)])
for _ in range(600):
 h,w=rng.randint(1,14),rng.randint(1,14)
 cases.append([''.join(rng.choices('..OOXX',k=w)) for i in range(h)])
assert len(cases)==1500
p=subprocess.run([sys.argv[1]],input='\n'.join('|'.join(b) for b in cases)+'\n',text=True,capture_output=True,check=True,timeout=50)
got=p.stdout.splitlines();assert len(got)==len(cases)
for i,(b,actual) in enumerate(zip(cases,got)):
 expected=oracle(b)
 assert actual==expected,(i,b,expected,actual)
print(f'PASS: {len(cases)} independent union-find Hex board comparisons')
