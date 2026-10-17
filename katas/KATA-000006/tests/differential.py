# SPDX-License-Identifier: MIT
"""Cross-language oracle using integer-ratio comparison; independent of Ruby implementation."""
import json,random,subprocess,sys
categories=['travel','groceries','entertainment','golf','restaurants']
rng=random.Random(20261017);cases=[]
for _ in range(330):
 current=[{'category':rng.choice(categories),'cents':rng.randint(0,50000)} for i in range(rng.randint(0,25))]
 previous=[{'category':rng.choice(categories),'cents':rng.randint(0,50000)} for i in range(rng.randint(0,25))]
 cases.append({'current':current,'previous':previous})
cases.extend([
 {'current':[{'category':'travel','cents':150}],'previous':[{'category':'travel','cents':100}]},
 {'current':[{'category':'travel','cents':149}],'previous':[{'category':'travel','cents':100}]},
 {'current':[{'category':'travel','cents':1}],'previous':[]},
 {'current':[{'category':'travel','cents':0}],'previous':[]}
])
def oracle(case):
 totals={category:[0,0] for category in categories}
 for p in case['current']:totals[p['category']][0]+=p['cents']
 for p in case['previous']:totals[p['category']][1]+=p['cents']
 return [{'category':category,'current_cents':current,'previous_cents':last}
         for category,(current,last) in sorted(totals.items())
         if current>0 and (last==0 or (current*2 >= last*3))]
p=subprocess.run(['ruby',sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,check=True,timeout=30)
results=json.loads(p.stdout)
assert len(results)==len(cases)
for i,(case,actual) in enumerate(zip(cases,results)):
 assert actual==oracle(case),(i,case,oracle(case),actual)
print(f'PASS: {len(cases)} independent payment-category differential scenarios')
