# SPDX-License-Identifier: MIT
"""Independent sequential Python Counter oracle for Go parallel worker maps."""
import collections,json,random,subprocess,sys
rng=random.Random(20261017);alphabet='abcXYZÉéüÜñÑΣσЖж!? 123\n😀';cases=[]
for _ in range(900):
 cases.append({'lines':[''.join(rng.choice(alphabet) for _ in range(rng.randint(0,150))) for __ in range(rng.randint(0,28))],'workers':rng.randint(1,32)})
for w in (1,2,3,4,8,16,32):cases.append({'lines':['ASCII abc XYZ','École ÉÉ','Σσ','Жж','a'*5000],'workers':w})
def oracle(s):
 counts=collections.Counter()
 for line in s['lines']:
  for char in line:
   if char.isalpha():
    lower=char.lower();assert len(lower)==1
    counts[lower]+=1
 return {'count':dict(counts),'error':''}
p=subprocess.run([sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,timeout=60,check=True)
got=json.loads(p.stdout);assert len(got)==len(cases)
for i,(s,actual) in enumerate(zip(cases,got)):
 want=oracle(s)
 assert actual==want,(i,s,want,actual)
print(f'PASS: {len(cases)} independent parallel frequency workloads')
