// SPDX-License-Identifier: MIT
// Independent declarative trace grammar, not another Java retry loop.
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const grammar={C:['c!'],S:['c+','s!','d'],R:['c+','s+','r!','d'],B:['c+','s+','r=BAD','d'],O:['c+','s+','r=OK','d']};
const alphabet=Object.keys(grammar),cases=[];
for(const a of alphabet)for(const b of alphabet)for(const c of alphabet)cases.push([a,b,c]);
let seed=20261019;
function next(max){seed=(Math.imul(seed,1103515245)+12345)>>>0;return seed%max;}
for(let i=0;i<800;i++)cases.push([alphabet[next(5)],alphabet[next(5)],alphabet[next(5)]]);
function expected(tokens){
  const success=tokens.indexOf('O');
  const used=tokens.slice(0,success===-1?3:success+1);
  return (success===-1?'0':'1')+'|'+used.flatMap(t=>grammar[t]).join(',');
}
const result=spawnSync('java',['-cp',process.argv[2],'TelemetryCli'],{
  input:cases.map(x=>x.join(',')).join('\n')+'\n',
  encoding:'utf8',timeout:30000,maxBuffer:20*1024*1024
});
if(result.status!==0)throw Error('Java failed: '+result.stderr);
const actual=result.stdout.trim().split('\n');
assert.equal(actual.length,cases.length);
for(let i=0;i<cases.length;i++)assert.equal(actual[i],expected(cases[i]),'case '+i);
console.log('PASS: '+cases.length+' grammar-generated independent telemetry traces (125 exhaustive + 800 seeded)');
