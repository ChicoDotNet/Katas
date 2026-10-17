# SPDX-License-Identifier: MIT
"""Independent Python aggregation oracle for original Swift racing rankings."""
import json,random,subprocess,sys
rng=random.Random(20261017);cases=[]
for _ in range(300):
 races=[]
 for __ in range(rng.randint(0,15)):
  pool=[f'D{i}' for i in range(9)]
  rng.shuffle(pool);size=rng.randint(1,10)
  names=[]
  for i in range(size):
   if rng.random()<0.25 or not pool:
    names.append(None)
   else:
    names.append(pool.pop())
  races.append(names)
 cases.append({'races':races})
POINTS=(25,18,15,12,10,8,6,4,2,1)
def oracle(case):
 season={}
 for race in case['races']:
  for index,name in enumerate(race):
   if name is not None:season[name]=season.get(name,0)+POINTS[index]
 return [{'driver':driver,'points':points} for driver,points in sorted(season.items(),key=lambda kv:(-kv[1],kv[0]))]
run=subprocess.run([sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,timeout=30,check=True)
found=json.loads(run.stdout)
assert len(found)==len(cases)
for i,(case,actual) in enumerate(zip(cases,found)):
 assert actual==oracle(case),(i,case,oracle(case),actual)
print(f'PASS: {len(cases)} independent Swift ranking comparisons')
