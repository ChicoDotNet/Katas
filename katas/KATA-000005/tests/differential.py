# SPDX-License-Identifier: MIT
"""Independent transition-table Python model for original Go rover solution."""
import json,random,subprocess,sys
binary=sys.argv[1]
HEADINGS='NESW'
def oracle(s):
 world,p,actions=s['World'],dict(s['Pose']),s['Commands']
 w,h=world['Width'],world['Height']
 obstacles={(x['X'],x['Y']) for x in world['Obstacles']}
 facing=HEADINGS.index(p['Facing'])
 for i,a in enumerate(actions):
  if a in 'lr':
   facing=(facing+(-1 if a=='l' else 1))%4
   p['Facing']=HEADINGS[facing]
   continue
  step={'N':(0,1),'E':(1,0),'S':(0,-1),'W':(-1,0)}[HEADINGS[facing]]
  multiplier=1 if a=='f' else -1
  x=(p['X']+step[0]*multiplier)%w;y=(p['Y']+step[1]*multiplier)%h
  if (x,y) in obstacles:return {'Pose':p,'Blocked':True,'Obstacle':{'X':x,'Y':y},'Applied':i}
  p['X'],p['Y']=x,y
 return {'Pose':p,'Blocked':False,'Obstacle':None,'Applied':len(actions)}
rng=random.Random(20261017);cases=[]
for _ in range(360):
 w,h=rng.randint(2,11),rng.randint(2,10)
 obstacles=[{'X':x,'Y':y} for x in range(w) for y in range(h) if rng.random()<0.12]
 cases.append({'World':{'Width':w,'Height':h,'Obstacles':obstacles},'Pose':{'X':rng.randrange(w),'Y':rng.randrange(h),'Facing':rng.choice(HEADINGS)},'Commands':''.join(rng.choices('fblr',k=rng.randrange(0,80)))})
run=subprocess.run([binary],input=json.dumps(cases),text=True,capture_output=True,check=True)
outputs=json.loads(run.stdout)
assert len(outputs)==len(cases)
for i,(scenario,out) in enumerate(zip(cases,outputs)):
 expect=oracle(scenario)
 assert out['Error']=='' and out['Result']==expect,(i,scenario,expect,out)
print(f'PASS: {len(cases)} seeded cross-language differential cases')
