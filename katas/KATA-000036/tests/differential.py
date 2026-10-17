# SPDX-License-Identifier: MIT
"""Independent Python rank histogram and category evaluation."""
import collections,json,random,subprocess,sys
rng=random.Random(20261017)
ranks='23456789TJQKA';deck=[r+s for r in ranks for s in 'CDHS']
def strength(hand):
 cards=hand.split();nums=[ranks.index(c[0])+2 for c in cards]
 freq=collections.Counter(nums)
 groups=sorted(((count,rank) for rank,count in freq.items()),reverse=True)
 desc=sorted(nums,reverse=True);seq=sorted(set(nums))
 high=5 if seq==[2,3,4,5,14] else (max(seq) if len(seq)==5 and max(seq)-min(seq)==4 else 0)
 flush=len({c[1] for c in cards})==1
 if high and flush:return (8,high)
 if groups[0][0]==4:return (7,groups[0][1],groups[1][1])
 if [n for n,_ in groups]==[3,2]:return (6,groups[0][1],groups[1][1])
 if flush:return (5,*desc)
 if high:return (4,high)
 if groups[0][0]==3:return (3,groups[0][1],*sorted((r for r,n in freq.items() if n==1),reverse=True))
 if [n for n,_ in groups]==[2,2,1]:
  return (2,*sorted((r for r,n in freq.items() if n==2),reverse=True),next(r for r,n in freq.items() if n==1))
 if groups[0][0]==2:return (1,groups[0][1],*sorted((r for r,n in freq.items() if n==1),reverse=True))
 return (0,*desc)
cases=[]
for _ in range(750):
 hands=[' '.join(rng.sample(deck,5)) for _ in range(rng.randint(1,12))]
 if rng.random()<0.1:hands.append(hands[0])
 cases.append(hands)
cases.extend([
 ['AH KH QH JH TH','AS KS QS JS TS'],
 ['2H 3H 4H 5H AH','3C 4D 5S 6H 7D'],
 ['2C 2D 2H 3S 3C','9H TH JH QH KH'],
 ['AS AD AH AC 2C','KS KD KH KC QD'],
 ['AC AD AH KD KC','QS QD QH JC JD'],
 ['2H 4H 6H 8H TH','2S 3D 4H 5C 6D'],
 ['2H 2D 3H 3D 4C','2C 2S 3C 3S 5D'],
 ['AC AD KH QS 8C','AS AH KC QD 7H'],
 ['2C 4D 6S 8H TS','3C 5D 7S 9H JS'],
 []
])
p=subprocess.run(['ruby',sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,timeout=35,check=True)
got=json.loads(p.stdout);assert len(got)==len(cases)
for i,(hands,actual) in enumerate(zip(cases,got)):
 scores=list(map(strength,hands))
 best=max(scores) if scores else None
 expected=[h for h,s in zip(hands,scores) if s==best]
 assert actual==expected,(i,hands,expected,actual)
print(f'PASS: {len(cases)} independent poker hand-ranking scenarios')
