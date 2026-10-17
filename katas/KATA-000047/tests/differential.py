# SPDX-License-Identifier: MIT
"""Independent division-based VLQ reference; random valid streams and malformed bytes."""
import json,random,subprocess,sys
rng=random.Random(20261017);MAX=2**32-1
def encode(vals):
 out=[]
 for value in vals:
  digits=[]
  while True:
   value,rem=divmod(value,128);digits.append(rem)
   if value==0:break
  out.extend([v+128 for v in reversed(digits[1:])]+[digits[0]])
 return out
def decode(data):
 values=[];groups=[]
 for byte in data:
  if not isinstance(byte,int) or not(0<=byte<=255):return None
  groups.append(byte)
  if len(groups)>5 or (len(groups)==1 and byte%128==0 and byte>=128):return None
  if byte<128:
   number=sum((b%128)*128**(len(groups)-i-1) for i,b in enumerate(groups))
   if number>MAX:return None
   values.append(number);groups=[]
 return None if groups else values
cases=[];expected=[]
for i in range(300):
 values=[rng.randrange(MAX+1) for j in range(rng.randint(0,20))]
 if i==0:values += [0,127,128,16383,16384,MAX]
 cases.append({'action':'encode','values':values});expected.append({'ok':True,'result':encode(values)})
 cases.append({'action':'decode','values':encode(values)});expected.append({'ok':True,'result':values})
for _ in range(400):
 data=[rng.randrange(256) for j in range(rng.randint(0,12))]
 want=decode(data)
 cases.append({'action':'decode','values':data})
 expected.append({'ok':want is not None,**({'result':want} if want is not None else {})})
for value in ([-1],[MAX+1],[3.5]):
 cases.append({'action':'encode','values':value});expected.append({'ok':False})
p=subprocess.run(['php',sys.argv[1]],input=json.dumps(cases),capture_output=True,text=True,check=True,timeout=30)
results=json.loads(p.stdout);assert len(results)==len(expected)
for i,(actual,want) in enumerate(zip(results,expected)):
 assert actual==want,(i,cases[i],want,actual)
print(f'PASS: {len(cases)} independently generated VLQ encode/decode and malformed-input cases')
