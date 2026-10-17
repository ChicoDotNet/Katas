// SPDX-License-Identifier: MIT
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
let seed=20261017;
const rand=max=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%max;};
const cases=[];
for(const x of [0,1,127,128,16383,16384,4294967295]){
 cases.push({action:'encode',values:[x]});
}
for(let i=0;i<340;i++){
 const values=Array.from({length:rand(18)},()=>rand(4294967295));
 cases.push({action:'encode',values});
}
for(const input of [[0],[127],[129,0],[143,255,255,255,127],
                    [128],[128,0],[129,128,128,128,128,0],[144,128,128,128,0],[256]]) {
 cases.push({action:'decode',values:input});
}
for(let i=0;i<320;i++){
 cases.push({action:'decode',values:Array.from({length:rand(15)},()=>rand(260))});
}
for(const bad of [-1,4294967296])cases.push({action:'encode',values:[bad]});
function run(command,args,input){
 const p=spawnSync(command,args,{input,encoding:'utf8',timeout:60000,maxBuffer:32*1024*1024});
 if(p.status!==0)throw Error(command+' failed: '+p.stderr);
 return p.stdout.trimEnd();
}
const [phpCli,rustBinary,adaBinary]=process.argv.slice(2);
const wanted=JSON.parse(run('php',[phpCli],JSON.stringify(cases)));
const input=cases.map(c=>(c.action==='encode'?'E':'D')+'|'+c.values.join(',')).join('\n')+'\n';
for(const [language,binary] of [['Rust',rustBinary],['Ada',adaBinary]]){
 const outputs=run(binary,[],input).split('\n');
 assert.equal(outputs.length,cases.length);
 for(let i=0;i<cases.length;i++){
  const line=outputs[i],want=wanted[i];
  if(!want.ok)assert.equal(line,'ERROR',language+' error contract case '+i);
  else assert.equal(line,'OK|'+want.result.join(','),language+' valid case '+i);
 }
 console.log('PASS: '+language+' VLQ agrees with PHP contract in '+cases.length+' cases');
}
