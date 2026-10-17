# SPDX-License-Identifier: MIT
"""Independent exhaustive backtracking oracle over physically distinct edge indices."""
import json,random,subprocess,sys
from collections import Counter
from itertools import combinations_with_replacement
rng=random.Random(20261017)
def can_cycle(tiles):
    if not tiles:return True
    def seek(used,at,first):
        if used==(1<<len(tiles))-1:return at==first
        for i,(a,b) in enumerate(tiles):
            if used>>i&1:continue
            for x,y in ((a,b),(b,a)):
                if at==x and seek(used|(1<<i),y,first):return True
        return False
    for a,b in (tiles[0],tiles[0][::-1]):
        if seek(1,b,a):return True
    return False
def check_output(tiles,answer):
    assert isinstance(answer['possible'],bool)
    if not answer['possible']:
        assert answer['chain']==[]
        return
    chain=answer['chain'];assert len(chain)==len(tiles)
    if chain:assert chain[0]['a']==chain[-1]['b']
    for i,t in enumerate(chain):
        if i:assert chain[i-1]['b']==t['a']
    normalize=lambda a,b:tuple(sorted((a,b)))
    assert Counter(normalize(*e) for e in tiles)==Counter(normalize(t['a'],t['b']) for t in chain)
cases=[[],[(0,0)],[(1,2)],[(1,1),(2,2)],[(1,2),(2,3),(3,1)],[(1,2),(2,4),(2,4),(2,3),(3,1)]]
edges=[(a,b) for a in range(3) for b in range(a,3)]
cases.extend(list(combo) for combo in combinations_with_replacement(edges,3))
for _ in range(650):
    cases.append([(rng.randrange(5),rng.randrange(5)) for _ in range(rng.randint(0,8))])
for _ in range(240):
    n=rng.randint(1,8);points=[rng.randrange(5) for _ in range(n)]
    tiles=[(points[i],points[(i+1)%n]) for i in range(n)]
    rng.shuffle(tiles)
    cases.append([t if rng.randrange(2) else t[::-1] for t in tiles])
p=subprocess.run([sys.argv[1]],input=json.dumps([[{'a':a,'b':b} for a,b in case] for case in cases]),text=True,capture_output=True,check=True,timeout=45)
answers=json.loads(p.stdout);assert len(answers)==len(cases)
for index,(tiles,answer) in enumerate(zip(cases,answers)):
    expected=can_cycle(tiles)
    assert answer['possible']==expected,(index,tiles,expected,answer)
    check_output(tiles,answer)
print(f'PASS: {len(cases)} independent brute-force multigraph scenarios and chain invariants')
