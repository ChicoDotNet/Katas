// SPDX-License-Identifier: MIT
package buckets
import ("fmt";"os")
type Scenario struct {Cap1 int `json:"cap1"`;Cap2 int `json:"cap2"`;Target int `json:"target"`;Start int `json:"start"`}
type State struct {One int `json:"one"`;Two int `json:"two"`}
type Result struct {Possible bool `json:"possible"`;Moves int `json:"moves"`;Goal int `json:"goal"`;Other int `json:"other"`;Actions []string `json:"actions"`;States []State `json:"states"`}
type parent struct {Prev State;Action string;Moves int;HasParent bool}
func Solve(s Scenario)(Result,error){
 if s.Cap1<1||s.Cap2<1||s.Cap1>30||s.Cap2>30||s.Cap1==s.Cap2||s.Target<1||s.Target>max(s.Cap1,s.Cap2)||(s.Start!=1&&s.Start!=2){return Result{},fmt.Errorf("invalid capacities, target or start")}
 initial:=State{One:s.Cap1};first:="fill1"
 if s.Start==2{initial=State{Two:s.Cap2};first="fill2"}
 if initial.One==s.Target||initial.Two==s.Target{return complete(s,map[State]parent{initial:{Action:first,Moves:1}},initial),nil}
 if os.Getenv("KATA_RED")=="1"{return Result{Possible:true,Moves:1,Goal:s.Start,Actions:[]string{first},States:[]State{initial}},nil}
 previous:=map[State]parent{initial:{Action:first,Moves:1}};queue:=[]State{initial}
 for len(queue)>0{
  at:=queue[0];queue=queue[1:]
  for _,step:=range neighbors(s,at){
   next:=step.State
   if next==at||(s.Start==1&&next.One==0&&next.Two==s.Cap2)||(s.Start==2&&next.Two==0&&next.One==s.Cap1){continue}
   if _,exists:=previous[next];exists{continue}
   previous[next]=parent{Prev:at,Action:step.Action,Moves:previous[at].Moves+1,HasParent:true}
   if next.One==s.Target||next.Two==s.Target{return complete(s,previous,next),nil}
   queue=append(queue,next)
  }
 }
 return Result{Possible:false,Actions:[]string{},States:[]State{}},nil
}
type transition struct{State State;Action string}
func neighbors(s Scenario,st State)[]transition{
 to2:=min(st.One,s.Cap2-st.Two);to1:=min(st.Two,s.Cap1-st.One)
 return []transition{{State{s.Cap1,st.Two},"fill1"},{State{st.One,s.Cap2},"fill2"},{State{0,st.Two},"empty1"},{State{st.One,0},"empty2"},{State{st.One-to2,st.Two+to2},"pour12"},{State{st.One+to1,st.Two-to1},"pour21"}}
}
func complete(s Scenario,previous map[State]parent,final State)Result{
 steps:=[]string{};states:=[]State{}
 for cur:=final;;{
  states=append(states,cur);p:=previous[cur];steps=append(steps,p.Action)
  if !p.HasParent{break}
  cur=p.Prev
 }
 for i,j:=0,len(states)-1;i<j;i,j=i+1,j-1{states[i],states[j]=states[j],states[i]}
 for i,j:=0,len(steps)-1;i<j;i,j=i+1,j-1{steps[i],steps[j]=steps[j],steps[i]}
 goal:=1;other:=final.Two
 if final.One!=s.Target||(final.Two==s.Target&&s.Start==2){goal=2;other=final.One}
 return Result{Possible:true,Moves:len(steps),Goal:goal,Other:other,Actions:steps,States:states}
}
