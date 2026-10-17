// SPDX-License-Identifier: MIT
package main
import("encoding/json";"fmt";"os";"ninja-katas/dominoes")
func main(){
 var cases [][]dominoes.Tile
 if err:=json.NewDecoder(os.Stdin).Decode(&cases);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
 answers:=make([]dominoes.Result,0,len(cases))
 for _,tiles:=range cases{answer,err:=dominoes.Solve(tiles);if err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)};answers=append(answers,answer)}
 if err:=json.NewEncoder(os.Stdout).Encode(answers);err!=nil{fmt.Fprintln(os.Stderr,err);os.Exit(2)}
}
