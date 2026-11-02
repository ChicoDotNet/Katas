// MIT — independent read-only event-log projection for KATA-000024.
// The TypeScript implementation updates indexes incrementally; this model
// scans the entire event log afresh for each query.
package main

import (
 "bytes"
 "encoding/json"
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "reflect"
 "strings"
)

type Event struct { Type string `json:"type"`; User string `json:"user,omitempty"`; Target string `json:"target,omitempty"`; From string `json:"from,omitempty"`; To string `json:"to,omitempty"`; Text string `json:"text,omitempty"` }
type Query struct { Type string `json:"type"`; User string `json:"user"` }
type Request struct { Events []Event `json:"events"`; Queries []Query `json:"queries"` }
type Post struct { ID int `json:"id"`; Author string `json:"author"`; Text string `json:"text"`; Mentions []string `json:"mentions"`; Links []string `json:"links"` }
type DM struct { ID int `json:"id"`; From string `json:"from"`; To string `json:"to"`; Text string `json:"text"` }
type Response struct { Results []any `json:"results"` }

func userChar(c byte) bool { return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_' }
func alpha(c byte) bool { return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' }
// Scanner uses explicit byte boundaries, not JS regex or the production index.
func mentions(text string) []string {
 found:=[]string{}; seen:=map[string]bool{}; b:=[]byte(text)
 for i:=0;i<len(b);i++ { if b[i]!='@' || i>0 && userChar(b[i-1]) {continue}; start:=i+1
  if start>=len(b)||!alpha(b[start]) {continue}; end:=start+1
  for end<len(b)&&userChar(b[end]) {end++}
  if end-start>32 {continue}
  who:=string(b[start:end]); if !seen[who] {seen[who]=true;found=append(found,who)}; i=end-1
 }
 return found
}
func links(text string) []string {
 found:=[]string{}; b:=[]byte(text)
 for i:=0;i<len(b);i++ {
  if !strings.HasPrefix(text[i:],"https://")&&!strings.HasPrefix(text[i:],"http://") {continue}
  start:=i; j:=i
  for j<len(b) && b[j]!=' ' && b[j]!='\n' && b[j]!='\t' && b[j]!='<' && b[j]!='>' && b[j]!='\'' && b[j]!='"' {j++}
  token:=strings.TrimRight(text[start:j],".,!?:;)")
  prefix:=strings.Index(token,"://")+3
  if prefix<len(token) && (alpha(token[prefix]) || token[prefix]>='0'&&token[prefix]<='9') {found=append(found,token)}
  i=j-1
 }
 return found
}
func project(req Request) Response {
 out:=Response{Results:make([]any,0,len(req.Queries))}
 for _,q:=range req.Queries {
  visible:=map[string]bool{}
  if q.Type=="feed" { for _,e:=range req.Events {if e.Type=="follow" && e.User==q.User && e.User!=e.Target {visible[e.Target]=true}} }
  posts:=[]Post{}; messages:=[]DM{}
  for i:=len(req.Events)-1;i>=0;i-- { e:=req.Events[i]
   if e.Type=="dm" && q.Type=="inbox" && e.To==q.User {messages=append(messages,DM{ID:i+1,From:e.From,To:e.To,Text:e.Text})}
   if e.Type!="post" {continue}
   tags:=mentions(e.Text)
   match:=q.Type=="timeline"&&e.User==q.User || q.Type=="feed"&&visible[e.User] || q.Type=="mentions"&&contains(tags,q.User)
   if match {posts=append(posts,Post{ID:i+1,Author:e.User,Text:e.Text,Mentions:tags,Links:links(e.Text)})}
  }
  if q.Type=="inbox" {out.Results=append(out.Results,messages)} else {out.Results=append(out.Results,posts)}
 }
 return out
}
func contains(xs []string,s string) bool {for _,x:=range xs {if x==s{return true}};return false}
func request(rng *rand.Rand, n int) Request {
 users:=[]string{"Alice","Bob","Charlie","Mallory","Zoe"}
 texts:=[]string{"hello","hello","@Alice hi @Alice","https://example.org/x?a=1,","mail a@Bob and @Charlie!","visit http://abc.test!","private data","@Zoe @Mallory","ordinary"}
 req:=Request{Events:[]Event{},Queries:[]Query{}}
 for i:=0;i<n;i++ {u:=users[rng.Intn(len(users))];v:=users[rng.Intn(len(users))];s:=texts[rng.Intn(len(texts))]
  switch rng.Intn(5) {case 0,1: req.Events=append(req.Events,Event{Type:"post",User:u,Text:s});case 2: req.Events=append(req.Events,Event{Type:"follow",User:u,Target:v});default:req.Events=append(req.Events,Event{Type:"dm",From:u,To:v,Text:s})}
 }
 for _,u:=range users {for _,kind:=range []string{"timeline","feed","mentions","inbox"} {req.Queries=append(req.Queries,Query{Type:kind,User:u})}}
 return req
}
func main(){
 cases:=1000; if os.Getenv("SOCIAL_CASES")=="MUTANT" {cases=150}
 rng:=rand.New(rand.NewSource(240024))
 requests:=make([]Request,0,cases+100); requests=append(requests,Request{Events:[]Event{},Queries:[]Query{{Type:"timeline",User:"Alice"},{Type:"inbox",User:"Alice"}}})
 for i:=0;i<cases;i++ {requests=append(requests,request(rng,rng.Intn(45)))}
 // Metamorphic: an unrelated DM appended at the end must not change any timeline/feed/mention projection.
 for i:=0;i<100;i++ {base:=request(rng,rng.Intn(30)); base.Queries=[]Query{{Type:"timeline",User:"Alice"},{Type:"feed",User:"Bob"},{Type:"mentions",User:"Charlie"}}
  requests=append(requests,base)
  clone:=Request{Events:append(append([]Event{},base.Events...),Event{Type:"dm",From:"Zoe",To:"Mallory",Text:"secret"}),Queries:base.Queries}
  requests=append(requests,clone)
 }
 var input bytes.Buffer; for _,r:=range requests {b,_:=json.Marshal(r);input.Write(b);input.WriteByte('\n')}
 cmd:=exec.Command("node","src/cli.mjs");cmd.Stdin=&input; var stderr bytes.Buffer;cmd.Stderr=&stderr
 raw,err:=cmd.Output();if err!=nil {fmt.Fprintln(os.Stderr,"CLI execution error:",err,stderr.String());os.Exit(2)}
 lines:=bytes.Split(bytes.TrimSpace(raw),[]byte("\n"));if len(lines)!=len(requests) {fmt.Fprintf(os.Stderr,"output line count %d != %d\n",len(lines),len(requests));os.Exit(1)}
 for i,r:=range requests {want:=project(r); var got Response
  if err:=json.Unmarshal(lines[i],&got);err!=nil {fmt.Fprintf(os.Stderr,"invalid response case %d: %v, %s\n",i,err,lines[i]);os.Exit(1)}
  var a,b any;wa,_:=json.Marshal(want);_ = json.Unmarshal(wa,&a);_ = json.Unmarshal(lines[i],&b)
  if !reflect.DeepEqual(a,b) {fmt.Fprintf(os.Stderr,"mismatch case %d\ninput: %s\nexpected: %s\nactual: %s\n",i,mustJSON(r),wa,lines[i]);os.Exit(1)}
 }
 // Check metamorphic pairs, preserving existing post IDs after appending a DM.
 offset:=1+cases; for j:=0;j<100;j++ {var a,b any;_ = json.Unmarshal(lines[offset+j*2],&a);_ = json.Unmarshal(lines[offset+j*2+1],&b);if !reflect.DeepEqual(a,b) {fmt.Fprintln(os.Stderr,"metamorphic unrelated-DM leak",j);os.Exit(1)}}
 fmt.Printf("GO INDEPENDENT EVENT-LOG ORACLE PASS: %d request histories, %d projection comparisons, 100 unrelated-DM metamorphic pairs\n",len(requests),2+cases*20+100*2*3)
}
func mustJSON(v any) string {b,_:=json.Marshal(v);return string(b)}
