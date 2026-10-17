# SPDX-License-Identifier: MIT
"""Independent Python deque oracle for C ring-buffer command histories."""
import random,subprocess,sys
from collections import deque
rng=random.Random(20261017);cases=[]
for _ in range(600):
 cap=rng.randint(1,18);ops=[]
 for __ in range(rng.randint(0,100)):
  op=rng.choice('WWWOORC')
  ops.append(op+(str(rng.randrange(-100000,100001)) if op in 'WO' else ''))
 cases.append((cap,ops))
def oracle(cap,ops):
 queue=deque();events=[]
 for op in ops:
  code=op[0]
  if code=='C':queue.clear();events.append('1')
  elif code=='R':events.append('1:'+str(queue.popleft()) if queue else '0')
  else:
   v=int(op[1:])
   if len(queue)==cap and code=='W':events.append('0')
   else:
    if len(queue)==cap:queue.popleft()
    queue.append(v);events.append('1')
 return ';'.join(events)+'|'+str(len(queue))+'|'+','.join(map(str,queue))
lines=[str(cap)+'|'+';'.join(ops) for cap,ops in cases]
p=subprocess.run([sys.argv[1]],input='\n'.join(lines)+'\n',capture_output=True,text=True,check=True,timeout=30)
out=p.stdout.splitlines();assert len(out)==len(cases)
for i,((cap,ops),got) in enumerate(zip(cases,out)):
 want=oracle(cap,ops)
 assert got==want,(i,cap,ops,want,got)
print(f'PASS: {len(cases)} independent FIFO/overwrite ring histories')
