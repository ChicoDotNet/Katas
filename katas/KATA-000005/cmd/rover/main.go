// SPDX-License-Identifier: MIT
package main
import (
 "encoding/json"
 "fmt"
 "os"
 rover "ninja-katas/marsrover"
)
type scenario struct{World rover.World;Pose rover.Pose;Commands string}
type output struct{Result rover.Result;Error string}
func main(){
 var scenarios []scenario
 if err:=json.NewDecoder(os.Stdin).Decode(&scenarios);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
 results:=make([]output,0,len(scenarios))
 for _,s:=range scenarios{r,err:=rover.Navigate(s.World,s.Pose,s.Commands);o:=output{Result:r};if err!=nil{o.Error=err.Error()};results=append(results,o)}
 if err:=json.NewEncoder(os.Stdout).Encode(results);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
}
