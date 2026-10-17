# SPDX-License-Identifier: MIT
"""Independent layered minimum-distance oracle and step-by-step witness validation."""
import json,random,subprocess,sys
rng=random.Random(20261017)
def oracle(c1,c2,goal,start):
 initial=(c1,0) if start==1 else (0,c2)
 if goal in initial:return 1
 forbidden=(0,c2) if start==1 else (c1,0)
 seen={initial};layer={initial};steps=1
 while layer:
  following=set()
  for x,y in layer:
   d=min(x,c2-y);e=min(y,c1-x)
   for at in ((c1,y),(x,c2),(0,y),(x,0),(x-d,y+d),(x+e,y-e)):
    if at==forbidden or at==(x,y) or at in seen:continue
    if goal in at:return steps+1
    following.add(at)
  seen|=following;layer=following;steps+=1
 return None
cases=[]
for _ in range(1200):
 a=rng.randint(1,20);b=rng.randint(1,20)
 if a==b:b+=1
 cases.append({'cap1':a,'cap2':b,'target':rng.randint(1,max(a,b)),'start':rng.choice((1,2))})
p=subprocess.run([sys.argv[1]],input=json.dumps(cases),capture_output=True,text=True,check=True,timeout=40)
results=json.loads(p.stdout);assert len(results)==len(cases)
for i,(s,out) in enumerate(zip(cases,results)):
 assert out['error']=='',(i,s,out)
 result=out['result'];distance=oracle(s['cap1'],s['cap2'],s['target'],s['start'])
 if distance is None:
  assert not result['possible'],(i,s,result);continue
 assert result['possible'] and result['moves']==distance,(i,s,distance,result)
 states=result['states'];actions=result['actions'];assert len(states)==len(actions)==distance
 assert states[0]==({'one':s['cap1'],'two':0} if s['start']==1 else {'one':0,'two':s['cap2']})
 for j in range(1,len(states)):
  before=states[j-1];after=states[j];x,y=before['one'],before['two'];a,b=after['one'],after['two']
  delta=min(x,s['cap2']-y);other=min(y,s['cap1']-x)
  allowed={(s['cap1'],y),(x,s['cap2']),(0,y),(x,0),(x-delta,y+delta),(x+other,y-other)}
  assert (a,b) in allowed and (a,b)!=(x,y),(i,s,j)
  assert (a,b)!=((0,s['cap2']) if s['start']==1 else (s['cap1'],0))
 last=states[-1];goal=result['goal']
 assert last['one' if goal==1 else 'two']==s['target']
 assert result['other']==last['two' if goal==1 else 'one']
print(f'PASS: {len(cases)} independent shortest-distance queries and action witnesses')
