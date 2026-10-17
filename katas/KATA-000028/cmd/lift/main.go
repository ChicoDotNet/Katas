// SPDX-License-Identifier: MIT
package main
import("encoding/json";"os";"fmt";lift "ninja-katas/lift")
type Scenario struct{Max int;Start int;Calls []lift.Call}
type Output struct{ Events []lift.Event; Error string }
func main(){
 var scenarios []Scenario;if err:=json.NewDecoder(os.Stdin).Decode(&scenarios);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
 outputs:=make([]Output,0,len(scenarios))
 for _,s:=range scenarios{
  out:=Output{Events:[]lift.Event{}}
  e,err:=lift.New(s.Max,s.Start)
  if err==nil{for _,c:=range s.Calls{if err=e.Call(c.Source,c.Destination);err!=nil{break}}}
  if err!=nil{out.Error=err.Error();outputs=append(outputs,out);continue}
  for ticks:=0;e.Pending()&&ticks<10000;ticks++{out.Events=append(out.Events,e.Tick())}
  if e.Pending(){out.Error="tick budget exceeded"}
  outputs=append(outputs,out)
 }
 if err:=json.NewEncoder(os.Stdout).Encode(outputs);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
}
