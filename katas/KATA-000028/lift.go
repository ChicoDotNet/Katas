//go:build !kata_red
// SPDX-License-Identifier: MIT
package lift
// Tick advances at most one floor and emits one externally observable action.
// Queued calls use FIFO dispatch; a pickup or dropoff occurs on arrival.
func(e *Engine)Tick()Event{
 if e.active==nil {
  if len(e.queue)==0{return Event{e.floor,"idle"}}
  c:=e.queue[0];e.queue=e.queue[1:];e.active=&c;e.phase="pickup"
 }
 target:=e.active.Source
 if e.phase=="dropoff"{target=e.active.Destination}
 if e.floor<target{e.floor++}else if e.floor>target{e.floor--}
 action:="move"
 if e.floor==target{
  if e.phase=="pickup"{action="pickup";e.phase="dropoff"}else{action="dropoff";e.active=nil;e.phase=""}
 }
 return Event{e.floor,action}
}
