# SPDX-License-Identifier: MIT
"""Independent transition-table Python model, rather than C++ domain class."""
import random,subprocess,sys
rng=random.Random(20261017);cases=[]
for _ in range(420):
 rate=rng.randrange(0,2001);operations=[]
 for k in range(rng.randint(0,50)):
  op=rng.choice('AAPSR');operations.append((op,rng.randint(0,10),rng.randint(0,100000)))
 cases.append((rate,operations))
def oracle(case):
 rate,ops=case;states={'draft':0,'approved':1,'rejected':2,'shipped':3}
 state='draft';lines=[];good=bad=0
 for op,qty,cents in ops:
  success=False
  if op=='A' and state=='draft' and qty>0 and cents>=0:lines.append((qty,cents));success=True
  elif op=='P' and state=='draft' and lines:state='approved';success=True
  elif op=='R' and state in ('draft','approved'):state='rejected';success=True
  elif op=='S' and state=='approved':state='shipped';success=True
  good+=success;bad+=not success
 sub=sum(q*c for q,c in lines);tax=(sub*rate+5000)//10000
 return f'{states[state]};{sub};{tax};{sub+tax};{good};{bad}'
def line(case):
 rate,ops=case
 return str(rate)+''.join('|'+('A,'+str(q)+','+str(c) if op=='A' else op) for op,q,c in ops)
p=subprocess.run([sys.argv[1]],input='\n'.join(line(x) for x in cases)+'\n',capture_output=True,text=True,check=True,timeout=15)
results=p.stdout.splitlines();assert len(results)==len(cases)
for i,(case,out) in enumerate(zip(cases,results)):
 expect=oracle(case);assert out==expect,(i,case,expect,out)
print(f'PASS: {len(cases)} independent order-lifecycle differential scenarios')
