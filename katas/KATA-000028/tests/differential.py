# SPDX-License-Identifier: MIT
"""Independent event-scheduling reference; test complete lift traces."""
import json,random,subprocess,sys
rng=random.Random(20261017);cases=[]
for _ in range(300):
 top=rng.randint(0,12)
 cases.append({'Max':top,'Start':rng.randint(0,top),'Calls':[{'Source':rng.randint(0,top),'Destination':rng.randint(0,top)} for i in range(rng.randint(0,10))]})
def oracle(s):
 here=s['Start'];events=[]
 for job in s['Calls']:
  for target,final_action in ((job['Source'],'pickup'),(job['Destination'],'dropoff')):
   while here!=target:
    here+=1 if here<target else -1
    events.append({'Floor':here,'Action':final_action if here==target else 'move'})
   if not events or events[-1]['Floor']!=target or events[-1]['Action']!=final_action:
    events.append({'Floor':here,'Action':final_action})
 return {'Events':events,'Error':''}
p=subprocess.run([sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,check=True)
actual=json.loads(p.stdout);assert len(actual)==len(cases)
for i,(case,found) in enumerate(zip(cases,actual)):
 expected=oracle(case)
 assert found==expected,(i,case,expected,found)
print(f'PASS: {len(cases)} independent lift event traces')
