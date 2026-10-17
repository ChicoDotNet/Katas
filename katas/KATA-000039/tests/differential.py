# SPDX-License-Identifier: MIT
"""Generate syntax trees BEFORE independent SGF serialization; no parser used as expected oracle."""
import json,random,subprocess,sys
rng=random.Random(20261017)
alphabet='abZ 1]\\[;()\n'
def value():return ''.join(rng.choice(alphabet) for _ in range(rng.randint(0,15)))
def gen(depth=0):
    props={}
    for _ in range(rng.randint(0,3)):
        key=rng.choice(('A','B','C','FF','P'))
        props.setdefault(key,[]).extend(value() for _ in range(rng.randint(1,3)))
    children=[gen(depth+1) for _ in range(rng.randint(0,2) if depth<3 else 0)]
    return {'properties':props,'children':children}
def escaped(s):return ''.join(('\\'+ch) if ch in ']\\' else ch for ch in s)
def encode(node):
    seq=[node]
    while len(seq[-1]['children'])==1:seq.append(seq[-1]['children'][0])
    out='('
    for n in seq:
        out+=';'
        for k,vals in sorted(n['properties'].items()):
            out+=k+''.join('['+escaped(v)+']' for v in vals)
        out+=rng.choice(('', ' ', '\n'))
    for sub in seq[-1]['children']:out+=encode(sub)
    return out+')'
cases=[];expected=[]
for _ in range(330):
    ast=gen();cases.append(encode(ast));expected.append({'ok':True,'root':ast})
for bad in ('','()','(;A)','(;C[bad)','(;)(;)','garbage','(;A[1])junk','(;A[1]','(;A[\\', '(;A[1](;B[2])'):
    cases.append(bad);expected.append({'ok':False})
p=subprocess.run(['perl',sys.argv[1]],input=json.dumps(cases),capture_output=True,text=True,timeout=40,check=True)
out=json.loads(p.stdout)
assert len(out)==len(cases),(len(out),len(cases))
for i,(want,got) in enumerate(zip(expected,out)):
    assert want==got,(i,cases[i],want,got)
print(f'PASS: {len(cases)} generated-AST and malformed-document cases')
