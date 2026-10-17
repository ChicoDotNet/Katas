// SPDX-License-Identifier: MIT
import assert from 'node:assert/strict';
import {test} from 'node:test';
import {Reactor} from '../src/reactor.js';
test('single input propagates to observed compute cell',()=>{
 const r=new Reactor(),a=r.input(2),b=r.compute([a],v=>v*2),seen=[];
 r.observe(b,v=>seen.push(v));r.set(a,4);
 assert.equal(b.value,8);assert.deepEqual(seen,[8]);
});
test('diamond graph notifies only after stabilization, exactly once',()=>{
 const r=new Reactor(),a=r.input(1),b=r.compute([a],x=>x+2),c=r.compute([a],x=>x*2),d=r.compute([b,c],(x,y)=>x+y),seen=[];
 r.observe(d,x=>seen.push([x,b.value,c.value]));r.set(a,2);assert.deepEqual(seen,[[8,4,4]]);
});
test('equal stable value suppresses callback',()=>{
 const r=new Reactor(),a=r.input(2),b=r.compute([a],x=>x%2),seen=[];r.observe(b,x=>seen.push(x));r.set(a,4);assert.deepEqual(seen,[]);
});
test('unchanged input suppresses callbacks',()=>{
 const r=new Reactor(),a=r.input(1),b=r.compute([a],x=>x+1),seen=[];r.observe(b,x=>seen.push(x));r.set(a,1);assert.deepEqual(seen,[]);
});
test('unsubscribe removes listener',()=>{
 const r=new Reactor(),a=r.input(1),b=r.compute([a],x=>x+1),seen=[];const remove=r.observe(b,x=>seen.push(x));remove();r.set(a,3);assert.deepEqual(seen,[]);
});
test('independent cell gets no notification',()=>{
 const r=new Reactor(),a=r.input(1),unused=r.input(5),b=r.compute([unused],x=>x*2),seen=[];r.observe(b,x=>seen.push(x));r.set(a,4);assert.deepEqual(seen,[]);
});
test('reject foreign and unknown dependencies',()=>{
 const r=new Reactor(),other=new Reactor(),a=other.input(1);assert.throws(()=>r.compute([a],x=>x));
});
test('reject non-integer values',()=>{
 const r=new Reactor(),a=r.input(1);r.compute([a],x=>x);assert.throws(()=>r.set(a,0.5));assert.throws(()=>r.compute([a],x=>x/2));
});
test('transaction rolls back if compute throws',()=>{
 const r=new Reactor(),a=r.input(1);r.compute([a],x=>{if(x===2)throw Error('boom');return x+1});
 assert.throws(()=>r.set(a,2));assert.deepEqual(r.values(),[1,2]);
});
test('no reentrant writes within notifications',()=>{
 const r=new Reactor(),a=r.input(1),b=r.compute([a],x=>x+1);r.observe(b,()=>assert.throws(()=>r.set(a,9),/reentrant/));r.set(a,3);assert.deepEqual(r.values(),[3,4]);
});
