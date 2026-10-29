// SPDX-License-Identifier: MIT
/** Original promise-only time recording, with explicit optional/required GPS policies. */
export class RequiredGpsError extends Error {
  constructor(cause) { super('required GPS unavailable', {cause}); this.name='RequiredGpsError'; }
}
function validPosition(point) {
  if (!point || typeof point !== 'object' || Array.isArray(point)) return false;
  const {lat,lon}=point;
  return typeof lat==='number' && Number.isFinite(lat) && lat>=-90 && lat<=90 &&
    typeof lon==='number' && Number.isFinite(lon) && lon>=-180 && lon<=180;
}
export async function clockIn({mode,now,getGps,send}) {
  if(!['time','optional','required'].includes(mode))throw new TypeError('invalid mode');
  if(typeof now!=='function'||typeof send!=='function'||
      (mode!=='time'&&typeof getGps!=='function'))throw new TypeError('invalid dependencies');
  const at=now();
  if(!Number.isSafeInteger(at))throw new RangeError('invalid timestamp');
  let position;
  if(mode!=='time'){
    const attempts=mode==='required'?3:1;
    for(let i=0;i<attempts;i++){
      try{
        const candidate=await getGps();
        if(!validPosition(candidate))throw new RangeError('invalid GPS coordinates');
        position={lat:candidate.lat,lon:candidate.lon};
        break;
      }catch(error){
        if(mode==='required'&&i===attempts-1)throw new RequiredGpsError(error);
      }
    }
  }
  return await send(position?{at,position}:{at});
}
