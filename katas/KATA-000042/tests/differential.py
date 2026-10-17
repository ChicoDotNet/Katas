# SPDX-License-Identifier: MIT
"""Independent bottom-up assembly oracle vs PHP recursive adjacency reconstruction."""
import json,random,subprocess,sys
rng=random.Random(20261017);valid=[];invalid=[]
for _ in range(800):
 n=rng.randint(1,60)
 rows=[{'id':0,'parent':0}]+[{'id':i,'parent':rng.randrange(i)} for i in range(1,n)]
 rng.shuffle(rows);valid.append(rows)
for _ in range(200):
 n=rng.randint(2,30)
 rows=[{'id':0,'parent':0}]+[{'id':i,'parent':rng.randrange(i)} for i in range(1,n)]
 problem=rng.choice(('duplicate','missing','badparent','badroot'))
 if problem=='duplicate':rows[-1]=rows[0].copy()
 elif problem=='missing':rows.pop(next(i for i,r in enumerate(rows) if r['id']==0))
 elif problem=='badparent':next(r for r in rows if r['id']==1)['parent']=1
 else:next(r for r in rows if r['id']==0)['parent']=1
 rng.shuffle(rows);invalid.append(rows)
cases=valid+invalid
def oracle(rows):
 n=len(rows);parent={row['id']:row['parent'] for row in rows}
 nodes={i:{'id':i,'children':[]} for i in range(n)}
 for i in reversed(range(1,n)):nodes[parent[i]]['children'].insert(0,nodes[i])
 return nodes[0]
p=subprocess.run(['php',sys.argv[1]],input=json.dumps(cases),capture_output=True,text=True,check=True,timeout=40)
out=json.loads(p.stdout);assert len(out)==len(cases)
for i,(rows,actual) in enumerate(zip(cases,out)):
 expected={'ok':True,'tree':oracle(rows)} if i<len(valid) else {'ok':False}
 assert actual==expected,(i,rows,expected,actual)
print(f'PASS: {len(cases)} independently modeled record-tree scenarios')
