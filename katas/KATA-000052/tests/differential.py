# SPDX-License-Identifier: MIT
"""Independent full-tree direct path editor, not a crumb zipper."""
import copy,json,random,subprocess,sys
rng=random.Random(20261017)
def tree(depth=0):
 value=rng.randint(-10000,10000)
 return {'value':value,'left':tree(depth+1) if depth<4 and rng.random()<.65 else None,'right':tree(depth+1) if depth<4 and rng.random()<.65 else None}
def selected(root,path):
 node=root
 for step in path:node=node['left' if step=='L' else 'right']
 return node
def edit(root,path,op,value):
 node=selected(root,path)
 if op=='V':node['value']=value
 elif op=='SL':node['left']={'value':value,'left':None,'right':None}
 elif op=='SR':node['right']={'value':value,'left':None,'right':None}
cases=[];expected=[]
for _ in range(420):
 original=tree();current=copy.deepcopy(original);path='';ops=[]
 for step in range(rng.randint(1,40)):
  here=selected(current,path)
  options=['V','SL','SR']+(['U'] if path else [])
  options+=['L'] if here['left'] is not None else []
  options+=['R'] if here['right'] is not None else []
  op=rng.choice(options)
  if op in ('V','SL','SR'):
   value=rng.randint(-10000,10000);edit(current,path,op,value);ops.append({'op':op,'value':value})
  else:
   path=path[:-1] if op=='U' else path+op
   ops.append({'op':op})
 cases.append({'root':original,'ops':ops})
 expected.append({'root':current,'focusPath':path,'focusValue':selected(current,path)['value']})
p=subprocess.run(['node',sys.argv[1]],input=json.dumps(cases),text=True,capture_output=True,timeout=40,check=True)
got=json.loads(p.stdout);assert len(got)==len(expected)
for i,(want,actual) in enumerate(zip(expected,got)):assert want==actual,(i,cases[i],want,actual)
print(f'PASS: {len(cases)} independent persistent-tree edit histories')
