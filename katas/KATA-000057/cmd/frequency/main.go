// SPDX-License-Identifier: MIT
package main
import("encoding/json";"fmt";"os";freq "ninja-katas/letterfrequency/src")
type Case struct{Lines []string `json:"lines"`;Workers int `json:"workers"`}
type Response struct{Count map[string]int `json:"count"`;Error string `json:"error"`}
func main(){
 var cases []Case;if err:=json.NewDecoder(os.Stdin).Decode(&cases);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
 out:=make([]Response,0,len(cases))
 for _,s:=range cases{
  values,err:=freq.Count(s.Lines,s.Workers)
  answer:=Response{Count:map[string]int{}}
  if err!=nil{answer.Error=err.Error()}else{for ch,num:=range values{answer.Count[string(ch)]=num}}
  out=append(out,answer)
 }
 if err:=json.NewEncoder(os.Stdout).Encode(out);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
}
