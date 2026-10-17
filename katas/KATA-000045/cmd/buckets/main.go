// SPDX-License-Identifier: MIT
package main
import("encoding/json";"fmt";"os";buckets "ninja-katas/twobucket/src")
type Response struct{Result buckets.Result `json:"result"`;Error string `json:"error"`}
func main(){
 var scenarios []buckets.Scenario
 if err:=json.NewDecoder(os.Stdin).Decode(&scenarios);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
 replies:=make([]Response,0,len(scenarios))
 for _,s:=range scenarios{r,err:=buckets.Solve(s);x:=Response{Result:r};if err!=nil{x.Error=err.Error()};replies=append(replies,x)}
 if err:=json.NewEncoder(os.Stdout).Encode(replies);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
}
