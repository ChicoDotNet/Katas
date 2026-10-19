// SPDX-License-Identifier: MIT
import {clockIn} from './clock-in.mjs';
import {readFileSync} from 'node:fs';
const cases=JSON.parse(readFileSync(0,'utf8'));
const results=[];
for(const test of cases){
  const events=[];
  let gpsIndex=0;
  const getGps=async()=>{
    events.push('gps');
    const token=test.gps[gpsIndex++];
    if(token==='G')return {lat:19.5,lon:-99.1};
    if(token==='I')return {lat:95,lon:0};
    if(token==='J')return {lat:0,lon:181};
    if(token==='K')return {lat:90.5,lon:0};
    throw Error('gps failure');
  };
  const send=async record=>{
    events.push(record.position?'post+gps':'post+time');
    if(test.server==='F')throw Error('server failure');
    return 'receipt';
  };
  let status;
  try{
    const receipt=await clockIn({mode:test.mode,now:()=>1730000000000,getGps,send});
    status=receipt==='receipt'?'ok':'unexpected';
  }catch(error){status=error.name==='RequiredGpsError'?'gps-error':'server-error';}
  results.push({status,events});
}
process.stdout.write(JSON.stringify(results)+'\n');
