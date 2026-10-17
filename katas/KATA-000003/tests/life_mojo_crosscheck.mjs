// SPDX-License-Identifier: MIT
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const [pixi,manifest,mojoSource,fortranBinary]=process.argv.slice(2);
function run(command,args,input,timeout=180000){
 const p=spawnSync(command,args,{input,encoding:'utf8',timeout,maxBuffer:16*1024*1024});
 if(p.status!==0)throw Error(command+' failed status '+p.status+': '+p.stderr);
 return p.stdout;
}
function board(bits,h,w){
 const rows=[];
 for(let r=0;r<h;r++){
  let text='';
  for(let c=0;c<w;c++)text+=(bits>>(r*w+c))&1;
  rows.push(text);
 }
 return rows;
}
function packed(rows){
 let bits=0;
 for(let r=0;r<rows.length;r++)
  for(let c=0;c<rows[0].length;c++)
   if(rows[r][c]==='1')bits|=1<<(r*rows[0].length+c);
 return bits;
}
const tests=[];
for(const [h,w] of [[1,1],[2,3],[3,3]])
 for(let bits=0;bits<(1<<(h*w));bits++)tests.push([h,w,bits]);
let seed=20261017;
for(let i=0;i<100;i++){
 seed=(seed*1103515245+12345)%2147483647;
 tests.push([4,6,seed%(1<<24)]);
}
assert.equal(tests.length,678);
const output=run(pixi,['run','--manifest-path',manifest,'mojo','run',mojoSource],undefined,900000).trim().split('\n');
assert.equal(output.length,tests.length);
for(let i=0;i<tests.length;i++){
 const [h,w,bits]=tests[i],rows=board(bits,h,w);
 const input=h+' '+w+'\n'+rows.join('\n')+'\n';
 const actual=run(fortranBinary,[],input).trim().split('\n');
 assert.equal(Number(output[i]),packed(actual),'Mojo packed stencil mismatch '+i);
}
console.log('PASS: Mojo bitboard stencil and Fortran matrix agree on 678 boards');
