// SPDX-License-Identifier: MIT
import test from 'node:test';
import assert from 'node:assert/strict';
import {clockIn,RequiredGpsError} from '../src/clock-in.mjs';
import {redClockIn} from './red-clock-in.mjs';
const isRed=process.env.NINJA_RED==='1',subject=isRed?redClockIn:clockIn,stamp=1730000000000;
function deferred(){let resolve;const promise=new Promise(yes=>{resolve=yes;});return {promise,resolve};}
test('required GPS must resolve before posting; response returned',async()=>{
  const gps=deferred(),events=[];
  const p=subject({mode:'required',now:()=>stamp,getGps:()=>{events.push('gps');return gps.promise;},
    send:async record=>{events.push('send');assert.deepEqual(record,{at:stamp,position:{lat:19.5,lon:-99.1}});return 'receipt';}});
  await Promise.resolve();
  try{assert.deepEqual(events,['gps'],'POST began before required GPS completed');}
  catch(error){gps.resolve({lat:19.5,lon:-99.1});await p.catch(()=>{});throw error;}
  gps.resolve({lat:19.5,lon:-99.1});
  assert.equal(await p,'receipt');assert.deepEqual(events,['gps','send']);
});
if(!isRed){
  test('time-only never requests GPS',async()=>{
    const events=[];
    const result=await subject({mode:'time',now:()=>stamp,getGps:()=>{throw Error('unexpected GPS');},
      send:async record=>{events.push(record);return 201;}});
    assert.equal(result,201);assert.deepEqual(events,[{at:stamp}]);
  });
  test('optional GPS failure falls back exactly once',async()=>{
    let calls=0;const sent=[];
    const result=await subject({mode:'optional',now:()=>stamp,getGps:async()=>{calls++;throw Error('offline');},
      send:async record=>{sent.push(record);return 'receipt';}});
    assert.equal(result,'receipt');assert.equal(calls,1);assert.deepEqual(sent,[{at:stamp}]);
  });
  test('required GPS retries errors and invalid coordinates, then posts once',async()=>{
    const events=[],script=[()=>{throw Error('offline');},()=>({lat:91,lon:0}),()=>({lat:0,lon:180})];
    const result=await subject({mode:'required',now:()=>stamp,getGps:async()=>{events.push('gps');return script.shift()();},
      send:async record=>{events.push('send');assert.deepEqual(record,{at:stamp,position:{lat:0,lon:180}});return 201;}});
    assert.equal(result,201);assert.deepEqual(events,['gps','gps','gps','send']);
  });
  test('required GPS exhaustion rejects without sending',async()=>{
    let calls=0;
    await assert.rejects(subject({mode:'required',now:()=>stamp,getGps:async()=>{calls++;throw Error('offline');},
      send:async()=>{throw Error('unexpected POST');}}),RequiredGpsError);
    assert.equal(calls,3);
  });
  test('server error propagates and never retries GPS or send',async()=>{
    let gpsCalls=0,sendCalls=0;
    await assert.rejects(subject({mode:'required',now:()=>stamp,getGps:async()=>{gpsCalls++;return {lat:90,lon:-180};},
      send:async()=>{sendCalls++;throw Error('server offline');}}),/server offline/);
    assert.equal(gpsCalls,1);assert.equal(sendCalls,1);
  });
  test('invalid mode, dependencies, timestamp reject without side effects',async()=>{
    let sent=0;
    for(const input of [
      {mode:'bad',now:()=>stamp,send:async()=>{sent++;}},
      {mode:'required',now:()=>stamp,send:async()=>{sent++;}},
      {mode:'time',now:()=>NaN,send:async()=>{sent++;}},
    ])await assert.rejects(subject(input));
    assert.equal(sent,0);
  });
  test('optional invalid position drops GPS and posts time-only',async()=>{
    const posts=[];
    await subject({mode:'optional',now:()=>stamp,getGps:async()=>({lat:0,lon:181}),
      send:async record=>{posts.push(record);return 201;}});
    assert.deepEqual(posts,[{at:stamp}]);
  });
  test('timestamp sampled once even after required GPS retries',async()=>{
    let nowCalls=0,gpsCalls=0;
    await subject({mode:'required',now:()=>{nowCalls++;return stamp;},
      getGps:async()=>{gpsCalls++;if(gpsCalls<3)throw Error('offline');return {lat:-90,lon:180};},
      send:async record=>{assert.equal(record.at,stamp);return 201;}});
    assert.equal(nowCalls,1);
  });
}
