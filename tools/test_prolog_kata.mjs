// SPDX-License-Identifier: MIT
// Node handles transport only; SWI-Prolog provides the distinct graph model.
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
let seed=20261017;
const random=(max)=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%max;};
function run(cmd,args,input){
  const p=spawnSync(cmd,args,{input,encoding:'utf8',timeout:60000,maxBuffer:32*1024*1024});
  if(p.status!==0)throw Error(cmd+' exited '+p.status+': '+p.stderr);
  return p.stdout.trim();
}
function dominoes(oracle,goBinary){
  const cases=[[],[{a:0,b:0}],[{a:1,b:2}],[{a:1,b:2},{a:2,b:1}]];
  for(let j=0;j<450;j++){
    const len=random(10),tiles=[];
    for(let i=0;i<len;i++)tiles.push({a:random(6),b:random(6)});
    cases.push(tiles);
  }
  const input=JSON.stringify(cases);
  const expected=JSON.parse(run('swipl',['-q','-s',oracle],input));
  const actual=JSON.parse(run(goBinary,[],input));
  assert.equal(actual.length,expected.length);
  for(let i=0;i<cases.length;i++){
    assert.equal(actual[i].possible,expected[i],'dominoes case '+i);
    if(actual[i].possible)assert.equal(actual[i].chain.length,cases[i].length);
  }
  console.log('PASS: '+cases.length+' Prolog parity/connectivity vs Go Euler circuit decisions');
}
function connect(oracle,cppBinary){
  const cases=[['.'],['O'],['X'],['O.','O.'],['XX','..']];
  for(let k=0;k<450;k++){
    const h=1+random(8),w=1+random(8),grid=[];
    for(let i=0;i<h;i++){
      let row='';
      for(let j=0;j<w;j++)row+='..OOXX'[random(6)];
      grid.push(row);
    }
    cases.push(grid);
  }
  const expected=JSON.parse(run('swipl',['-q','-s',oracle],JSON.stringify(cases)));
  const actual=run(cppBinary,[],cases.map(b=>b.join('|')).join('\n')+'\n').split('\n');
  assert.equal(actual.length,expected.length);
  for(let i=0;i<cases.length;i++)assert.equal(actual[i],expected[i],'hex case '+i);
  console.log('PASS: '+cases.length+' Prolog relational path vs C++ Hex decisions');
}
const [mode,oracle,binary]=process.argv.slice(2);
if(mode==='dominoes')dominoes(oracle,binary);
else if(mode==='connect')connect(oracle,binary);
else throw Error('Usage: node test_prolog_kata.mjs dominoes|connect oracle binary');
