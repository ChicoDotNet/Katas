// SPDX-License-Identifier: MIT
// Independent decision-table reference: classify GPS outcomes before considering POST.
package main
import (
    "bytes"
    "encoding/json"
    "fmt"
    "os"
    "os/exec"
    "reflect"
)
type Scenario struct {
    Mode string `json:"mode"`
    GPS []string `json:"gps"`
    Server string `json:"server"`
}
type Result struct {
    Status string `json:"status"`
    Events []string `json:"events"`
}
func reference(s Scenario) Result {
    r:=Result{Events:make([]string,0,4)}
    withPosition:=false
    switch s.Mode {
    case "time":
    case "optional":
        r.Events=append(r.Events,"gps")
        withPosition=s.GPS[0]=="G"
    case "required":
        firstGood:=-1
        for i,token:=range s.GPS {if token=="G" {firstGood=i;break}}
        count:=3
        if firstGood>=0 {count=firstGood+1;withPosition=true}
        for i:=0;i<count;i++ {r.Events=append(r.Events,"gps")}
        if !withPosition {r.Status="gps-error";return r}
    default: panic("unsupported mode in oracle")
    }
    if withPosition {r.Events=append(r.Events,"post+gps")
    }else{r.Events=append(r.Events,"post+time")}
    if s.Server=="F" {r.Status="server-error"}else{r.Status="ok"}
    return r
}
func main(){
    if len(os.Args)!=2 {panic("Usage: go run tests/oracle.go src/cli.mjs")}
    alphabet:=[]string{"G","F","I","J","K"}
    modes:=[]string{"time","optional","required"}
    servers:=[]string{"O","F"}
    cases:=make([]Scenario,0,1550)
    for _,mode:=range modes {for _,a:=range alphabet {for _,b:=range alphabet {for _,c:=range alphabet {for _,server:=range servers {
        cases=append(cases,Scenario{Mode:mode,GPS:[]string{a,b,c},Server:server})
    }}}}}
    var seed uint32=20261019
    random:=func(max uint32)int{seed=seed*1664525+1013904223;return int(seed%max)}
    for i:=0;i<800;i++{
        cases=append(cases,Scenario{Mode:modes[random(3)],GPS:[]string{alphabet[random(5)],alphabet[random(5)],alphabet[random(5)]},Server:servers[random(2)]})
    }
    input,err:=json.Marshal(cases);if err!=nil{panic(err)}
    cmd:=exec.Command("node",os.Args[1]);cmd.Stdin=bytes.NewReader(input)
    output,err:=cmd.CombinedOutput();if err!=nil{panic(fmt.Sprintf("Node failed: %v: %s",err,output))}
    var actual []Result
    if err=json.Unmarshal(output,&actual);err!=nil{panic(fmt.Sprintf("Invalid Node response: %v: %s",err,output))}
    if len(actual)!=len(cases){panic(fmt.Sprintf("Expected %d results, got %d",len(cases),len(actual)))}
    for i,s:=range cases{
        want:=reference(s)
        if !reflect.DeepEqual(actual[i],want){panic(fmt.Sprintf("case %d: %+v\nexpected %+v, got %+v",i,s,want,actual[i]))}
    }
    fmt.Printf("PASS: %d independent Go decision-table outcomes (750 exhaustive + 800 seeded)\n",len(cases))
}
