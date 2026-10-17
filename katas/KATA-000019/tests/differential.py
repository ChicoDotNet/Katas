# SPDX-License-Identifier: MIT
"""Independent Python list model and seeded expand-contract commands."""
import random,subprocess,sys
rng=random.Random(20261017);cases=[]
for _ in range(400):
 ops=[]
 for _ in range(rng.randint(0,20)):
  op=rng.choice('SAB')
  if op=='B':ops.append('B:'+','.join(str(rng.randint(0,100000)) for _ in range(rng.randint(0,7))))
  else:ops.append(op+':'+str(rng.randint(0,100000)))
 cases.append(';'.join(ops))
def oracle(line):
 items=[]
 for command in line.split(';'):
  if not command:continue
  name,raw=command.split(':',1)
  if name=='S':items=[int(raw)]
  elif name=='A':items.append(int(raw))
  elif name=='B':items=[int(x) for x in raw.split(',')] if raw else []
 return ('-' if not items else str(items[0]))+'|'+str(sum(items))+'|'+','.join(map(str,items))
run=subprocess.run(['java','-cp',sys.argv[1],'CartCli'],input='\n'.join(cases)+'\n',text=True,capture_output=True,check=True)
got=run.stdout.splitlines();assert len(got)==len(cases)
for i,(line,out) in enumerate(zip(cases,got)):
 assert out==oracle(line),(i,line,oracle(line),out)
print(f'PASS: {len(cases)} independent parallel-change command sequences')
