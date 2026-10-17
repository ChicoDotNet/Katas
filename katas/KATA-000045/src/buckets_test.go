// SPDX-License-Identifier: MIT
package buckets
import "testing"
func TestInitialBucketFill(t *testing.T){
 for _,scenario:=range []struct{s Scenario;goal int}{{Scenario{3,5,3,1},1},{Scenario{3,5,5,2},2}}{
  r,err:=Solve(scenario.s)
  if err!=nil||!r.Possible||r.Moves!=1||r.Goal!=scenario.goal||len(r.States)!=1{t.Fatalf("initial solution wrong %+v err=%v",r,err)}
 }
}
func TestShortestPourAndNoForbidden(t *testing.T){
 r,err:=Solve(Scenario{3,5,1,1})
 if err!=nil||!r.Possible||r.Moves!=4{t.Fatalf("wrong shortest solution %+v %v",r,err)}
 for i,at:=range r.States{if at.One==0&&at.Two==5{t.Fatalf("forbidden state %d %+v",i,at)}}
 if r.Goal!=1||r.States[len(r.States)-1].One!=1{t.Fatalf("wrong finishing bucket %+v",r)}
}
func TestUnsolvableAndBadInput(t *testing.T){
 r,err:=Solve(Scenario{4,6,5,1});if err!=nil||r.Possible{t.Fatalf("expected unsolvable %+v %v",r,err)}
 for _,s:=range []Scenario{{0,5,3,1},{3,3,2,1},{2,3,4,1},{2,3,2,3}}{if _,err:=Solve(s);err==nil{t.Fatalf("invalid accepted: %+v",s)}}
}
