# SPDX-License-Identifier: MIT
"""Independent Python modular exponent reference for Java BigInteger.modPow."""
import random,subprocess,sys
rng=random.Random(20261017)
primes=[n for n in range(5,4000) if all(n%d for d in range(2,int(n**0.5)+1))]
cases=[]
for _ in range(1000):
 p=rng.choice(primes);cases.append((p,rng.randint(2,p-2),rng.randint(2,p-2),rng.randint(2,p-2)))
cases += [(21,5,6,7),(23,1,3,4),(23,22,3,4),(23,5,1,4),(23,5,22,4)]
p=subprocess.run(['java','-cp',sys.argv[1],'Main'],input=''.join('|'.join(map(str,c))+'\n' for c in cases),text=True,capture_output=True,timeout=50,check=True)
got=p.stdout.splitlines();assert len(got)==len(cases)
for i,((prime,g,a,b),line) in enumerate(zip(cases,got)):
 if i>=1000:assert line=='ERROR',(i,line)
 else:
  pa=pow(g,a,prime);pb=pow(g,b,prime);secret=pow(pb,a,prime)
  assert secret==pow(pa,b,prime)
  assert line==f'{pa}|{pb}|{secret}',(i,line)
print(f'PASS: {len(cases)} independent modular key-exchange scenarios')
