# SPDX-License-Identifier: MIT
"""Independent Python scratch recomputation of reactive graph snapshots."""
import json,random,subprocess,sys,math
rng=random.Random(20261017);cases=[]
for _ in range(360):
 cells=[]
 for j in range(rng.randint(2,15)):
  if j<2 or rng.random()<0.35:cells.append({'kind':'input','value':rng.randrange(-100,101)})
  else:cells.append({'kind':'compute','deps':rng.sample(range(j),rng.randint(1,min(j,3))),'op':rng.choice(('sum','max','product'))})
 inputs=[i for i,c in enumerate(cells) if c['kind']=='input']
 cases.append({'cells':cells,'updates':[[rng.choice(inputs),rng.randrange(-100,101)] for k in range(rng.randint(1,18))]})
def oracle(s):
 cells=s['cells'];current={i:c['value'] for i,c in enumerate(cells) if c['kind']=='input'}
 def calculate():
  values=[]
  for i,c in enumerate(cells):
   if c['kind']=='input':values.append(current[i])
   else:
    args=[values[j] for j in c['deps']]
    values.append(sum(args) if c['op']=='sum' else max(args) if c['op']=='max' else math.prod(args)%997)
  return values
 prior=calculate();out=[]
 for i,x in s['updates']:
  current[i]=x;values=calculate()
  events=[[j,v] for j,v in enumerate(values) if cells[j]['kind']=='compute' and v!=prior[j]]
  out.append({'values':values,'events':events});prior=values
 return out
p=subprocess.run(['node',sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,check=True,timeout=50)
got=json.loads(p.stdout);assert len(got)==len(cases)
for index,(case,actual) in enumerate(zip(cases,got)):
 expected=oracle(case)
 assert actual==expected,(index,case,expected,actual)
print(f'PASS: {len(cases)} independent full-reactor DAG histories')
