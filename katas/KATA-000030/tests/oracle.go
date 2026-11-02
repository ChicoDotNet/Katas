// Independent decision-table oracle for the original Trip Service domain contract.
// Generates request ASTs first; expected results are computed without Ruby classes.
package main

import (
 "bytes"
 "encoding/json"
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "reflect"
)

type User struct { ID string `json:"id"`; Friends []string `json:"friends"`; Trips []string `json:"trips"` }
type Request struct { Viewer *string `json:"viewer"`; Target string `json:"target"`; Users []User `json:"users"` }
type Case struct { Request any; Expected map[string]any; Kind string }

func ptr(s string)*string{return &s}
func expected(req Request)map[string]any{
 if req.Viewer==nil{return map[string]any{"error":"not_logged_in"}}
 var target *User
 for i:=range req.Users {if req.Users[i].ID==req.Target{target=&req.Users[i];break}}
 if target==nil{return map[string]any{"error":"user_not_found"}}
 visible:=*req.Viewer==target.ID
 for _,friend:=range target.Friends{if friend==*req.Viewer{visible=true}}
 if !visible{return map[string]any{"trips":[]string{}}}
 trips:=append([]string{},target.Trips...)
 return map[string]any{"trips":trips}
}
func makeCase(req Request,kind string)Case{return Case{Request:req,Expected:expected(req),Kind:kind}}
func main(){
 if len(os.Args)!=2{panic("usage: go run tests/oracle.go path/to/cli.rb")}
 cases:=make([]Case,0,2000)
 viewers:=[]*string{nil,ptr("alice"),ptr("stranger"),ptr("target"),ptr("alice2")}
 targets:=[]string{"target","missing"}
 friendSets:=[][]string{{},{"alice"},{"alice2"},{"stranger"},{"alice","alice"},{"target"},{"alice2","alice"}}
 tripSets:=[][]string{{},{"T1"},{"T2","T1"},{"T1","T1"},{"á","👩‍💻"}}
 for _,viewer:=range viewers {for _,target:=range targets {for _,friends:=range friendSets {for _,trips:=range tripSets {
   req:=Request{Viewer:viewer,Target:target,Users:[]User{{ID:"target",Friends:friends,Trips:trips}}}
   cases=append(cases,makeCase(req,"exhaustive"))
 }}}}
 exhaustive:=len(cases)
 rng:=rand.New(rand.NewSource(30030))
 for i:=0;i<900;i++{
  viewer:=viewers[rng.Intn(len(viewers))];target:=targets[rng.Intn(len(targets))]
  friends:=append([]string{},friendSets[rng.Intn(len(friendSets))]...)
  trips:=append([]string{},tripSets[rng.Intn(len(tripSets))]...)
  if rng.Intn(3)==0 {friends=append(friends,"other")}
  if rng.Intn(4)==0 {trips=append(trips,"T3")}
  req:=Request{Viewer:viewer,Target:target,Users:[]User{{ID:"other",Friends:[]string{},Trips:[]string{"secret"}},{ID:"target",Friends:friends,Trips:trips}}}
  cases=append(cases,makeCase(req,"generated"))
 }
 metamorphic:=0
 // Metamorphic input transformations: friend-list permutations and unrelated users cannot affect visibility.
 for i:=0;i<200;i++{
  req:=Request{Viewer:ptr("alice"),Target:"target",Users:[]User{{ID:"target",Friends:[]string{"stranger","alice","other"},Trips:[]string{"T1","T2"}}}}
  if i%2==0 {req.Users[0].Friends=[]string{"other","alice","stranger"}}
  if i%3==0 {req.Users=append(req.Users,User{ID:"unrelated",Friends:[]string{},Trips:[]string{"hidden"}})}
  cases=append(cases,makeCase(req,"metamorphic"));metamorphic++
 }
 invalid:=[]any{
  map[string]any{},map[string]any{"viewer":"alice","target":"target"},
  map[string]any{"viewer":"alice","target":"target","users":42},
  map[string]any{"viewer":"alice","target":"target","users":[]any{map[string]any{"id":"target","friends":[]any{12},"trips":[]any{}}}},
  map[string]any{"viewer":"alice","target":"target","users":[]any{map[string]any{"id":"target","friends":[]any{},"trips":[]any{}},map[string]any{"id":"target","friends":[]any{},"trips":[]any{}}}},
  map[string]any{"viewer":"","target":"target","users":[]any{}},
  map[string]any{"viewer":"alice","target":"target","users":[]any{},"admin":true},
  []any{"not","a","request"},
 }
 for _,v:=range invalid {cases=append(cases,Case{Request:v,Expected:map[string]any{"error":"invalid_request"},Kind:"invalid"})}
 var input bytes.Buffer
 for _,c:=range cases {line,err:=json.Marshal(c.Request);if err!=nil{panic(err)};input.Write(line);input.WriteByte('\n')}
 cmd:=exec.Command("ruby",os.Args[1]);cmd.Stdin=&input
 out,err:=cmd.CombinedOutput();if err!=nil{fmt.Fprintf(os.Stderr,"ruby failed: %v\n%s\n",err,out);os.Exit(1)}
 lines:=bytes.Split(bytes.TrimSpace(out),[]byte{'\n'})
 if len(lines)!=len(cases){fmt.Fprintf(os.Stderr,"response count mismatch: %d != %d, output tail=%q\n",len(lines),len(cases),out[max(0,len(out)-200):]);os.Exit(1)}
 for i,c:=range cases {
  var got any;var want any
  if err:=json.Unmarshal(lines[i],&got);err!=nil{fmt.Fprintf(os.Stderr,"case %d invalid JSON: %v\n",i,err);os.Exit(1)}
  expectedBytes,_:=json.Marshal(c.Expected);_ = json.Unmarshal(expectedBytes,&want)
  if !reflect.DeepEqual(got,want){fmt.Fprintf(os.Stderr,"case %d %s mismatch: input=%#v want=%s got=%s\n",i,c.Kind,c.Request,expectedBytes,lines[i]);os.Exit(1)}
 }
 fmt.Printf("GO independent decision-table oracle PASS: %d exhaustive, 900 generated, %d metamorphic, %d invalid, total %d\n",exhaustive,metamorphic,len(invalid),len(cases))
}
