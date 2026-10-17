// SPDX-License-Identifier: MIT
import {Zipper,Tree} from './zipper';
declare const require:any;declare const process:any;
const fs=require('node:fs');
type Scenario={root:Tree;ops:{op:string;value?:number}[]};
const scenarios:Scenario[]=JSON.parse(fs.readFileSync(0,'utf8'));
const result=scenarios.map(s=>{
 let zipper=Zipper.from(s.root),path='';
 for(const operation of s.ops){
  if(operation.op==='L'){const next=zipper.left();if(!next)throw Error('invalid L');zipper=next;path+='L';}
  else if(operation.op==='R'){const next=zipper.right();if(!next)throw Error('invalid R');zipper=next;path+='R';}
  else if(operation.op==='U'){const next=zipper.up();if(!next)throw Error('invalid U');zipper=next;path=path.slice(0,-1);}
  else if(operation.op==='V'){zipper=zipper.setValue(operation.value!);}
  else if(operation.op==='SL'){zipper=zipper.setLeft({value:operation.value!,left:null,right:null});}
  else if(operation.op==='SR'){zipper=zipper.setRight({value:operation.value!,left:null,right:null});}
  else throw Error('unknown operation');
 }
 return {root:zipper.toRoot(),focusPath:path,focusValue:zipper.value()};
});
process.stdout.write(JSON.stringify(result)+'\n');
