// SPDX-License-Identifier: MIT
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const [ocamlBinary,perlCli] = process.argv.slice(2);
function run(cmd,args,input) {
 const p=spawnSync(cmd,args,{input,encoding:'utf8',timeout:60000,maxBuffer:16*1024*1024});
 if(p.status!==0)throw Error(cmd+' failed: '+p.stderr);
 return p.stdout;
}
const {sgf,expected}=JSON.parse(run(ocamlBinary,[],undefined));
const got=JSON.parse(run('perl',[perlCli],JSON.stringify(sgf)));
assert.equal(got.length,expected.length);
for(let i=0;i<sgf.length;i++)
 assert.deepStrictEqual(got[i],expected[i],'SGF AST '+i);
console.log('PASS: '+sgf.length+' OCaml-generated AST/SGF trees matched Perl parser');
