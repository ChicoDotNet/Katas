# SPDX-License-Identifier: MIT
"""Independent frame-based Python reference and complete game generator."""
import random,subprocess,sys
rng=random.Random(20261017)
def game():
 frames=[];rolls=[]
 for i in range(10):
  first=rng.randint(0,10)
  if i<9:
   if first==10:frames.append([10]);rolls.append(10)
   else:
    second=rng.randint(0,10-first);frames.append([first,second]);rolls.extend([first,second])
  else:
   if first==10:
    second=rng.randint(0,10);third=rng.randint(0,10 if second==10 else 10-second)
    frames.append([10,second,third]);rolls.extend([10,second,third])
   else:
    second=rng.randint(0,10-first)
    if first+second==10:
     third=rng.randint(0,10);frames.append([first,second,third]);rolls.extend([first,second,third])
    else:frames.append([first,second]);rolls.extend([first,second])
 return frames,rolls
def oracle(frames):
 result=0
 for i,f in enumerate(frames):
  if i==9:result+=sum(f);continue
  nextballs=[r for future in frames[i+1:] for r in future]
  if f[0]==10:result+=10+sum(nextballs[:2])
  elif sum(f)==10:result+=10+nextballs[0]
  else:result+=sum(f)
 return result
cases=[game() for _ in range(600)]
text=''.join(','.join(map(str,rolls))+'\n' for _,rolls in cases)
p=subprocess.run([sys.argv[1]],input=text,text=True,capture_output=True,check=True,timeout=20)
actual=p.stdout.splitlines();assert len(actual)==len(cases)
for i,((frames,rolls),got) in enumerate(zip(cases,actual)):
 expected=oracle(frames)
 assert got==str(expected),(i,frames,rolls,expected,got)
print(f'PASS: {len(cases)} frame-based independent bowling games')
