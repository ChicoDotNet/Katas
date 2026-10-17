// SPDX-License-Identifier: MIT
import { Reactor } from './reactor.js';
let data='';
for await (const chunk of process.stdin) data+=chunk;
const scenarios=JSON.parse(data);
const output=scenarios.map(scenario=>{
 const engine=new Reactor(),cells=[],events=[];
 for (const cell of scenario.cells){
  if (cell.kind==='input') cells.push(engine.input(cell.value));
  else if (cell.kind==='compute'){
   const fn=cell.op==='sum'?(...v)=>v.reduce((a,b)=>a+b,0)
    :cell.op==='max'?(...v)=>Math.max(...v)
    :cell.op==='product'?(...v)=>v.reduce((a,b)=>((a*b)%997+997)%997,1):null;
   if (!fn) throw Error('unknown op');
   cells.push(engine.compute(cell.deps.map(i=>cells[i]),fn));
  }else throw Error('unknown kind');
 }
 for(let i=0;i<cells.length;i++)if(scenario.cells[i].kind==='compute')engine.observe(cells[i],v=>events.push([i,v]));
 const snapshots=[];
 for(const [index,value] of scenario.updates){
  engine.set(cells[index],value);
  snapshots.push({values:engine.values(),events:events.splice(0)});
 }
 return snapshots;
});
console.log(JSON.stringify(output));
