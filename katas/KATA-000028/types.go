// SPDX-License-Identifier: MIT
package lift
import "fmt"
type Call struct{ Source int; Destination int }
type Event struct{ Floor int; Action string }
type Engine struct{ floor,max int; queue []Call; active *Call; phase string }
func New(maxFloor, initial int)(*Engine,error){
 if maxFloor<0||initial<0||initial>maxFloor{return nil,fmt.Errorf("invalid building")}
 return &Engine{max:maxFloor,floor:initial},nil
}
func (e *Engine) Call(source,destination int)error{
 if source<0||destination<0||source>e.max||destination>e.max{return fmt.Errorf("invalid floor")}
 e.queue=append(e.queue,Call{Source:source,Destination:destination});return nil
}
func(e *Engine) Floor()int{return e.floor}
func(e *Engine) Pending()bool{return e.active!=nil||len(e.queue)!=0}
