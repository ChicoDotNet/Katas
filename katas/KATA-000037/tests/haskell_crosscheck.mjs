// SPDX-License-Identifier: MIT
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const [haskellBin,reactorCli]=process.argv.slice(2);
function run(binary,args,input){
 const p=spawnSync(binary,args,{input,encoding:'utf8',timeout:60000,maxBuffer:16*1024*1024});
 if(p.status!==0)throw Error(binary+' exited '+p.status+': '+p.stderr);
 return p.stdout;
}
const data=JSON.parse(run(haskellBin,[],undefined));
const actual=JSON.parse(run('node',[reactorCli],JSON.stringify(data.cases)));
assert.equal(actual.length,data.expected.length);
for(let i=0;i<actual.length;i++)
 assert.deepStrictEqual(actual[i],data.expected[i],'Haskell snapshot case '+i);
console.log('PASS: '+actual.length+' Haskell pure full-snapshot DAG histories agree with JavaScript callbacks');
