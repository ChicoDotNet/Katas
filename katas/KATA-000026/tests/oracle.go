// Independent event-sourced reference: accepted commands are replayed from scratch
// for every observation. Kotlin uses an incrementally mutated aggregate.
package main
import (
 "bufio"
 "bytes"
 "encoding/base64"
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "regexp"
 "sort"
 "strings"
 "time"
)
type Event struct { op string; f []string }
type Task struct { id,project,title,date string; done bool; ordinal int }
type State struct { projects []string; tasks map[string]Task }
func fold(events []Event) State {
 s:=State{tasks:map[string]Task{}}
 for i,e:=range events {
  f:=e.f
  switch e.op {
  case "project": s.projects=append(s.projects,f[1])
  case "add": s.tasks[f[2]]=Task{id:f[2],project:f[1],title:f[3],date:"-",ordinal:i}
  case "done": t:=s.tasks[f[1]];t.done=true;s.tasks[f[1]]=t
  case "deadline": t:=s.tasks[f[1]];t.date=f[2];s.tasks[f[1]]=t
  case "delete": delete(s.tasks,f[1])
  }
 }
 return s
}
func hasProject(s State, name string) bool {for _,x:=range s.projects {if x==name{return true}};return false}
var idRe=regexp.MustCompile(`^[A-Za-z0-9]+$`)
var projectRe=regexp.MustCompile(`^[A-Za-z][A-Za-z ]*$`)
var dateRe=regexp.MustCompile(`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`)
func dateValid(d string) bool {if !dateRe.MatchString(d){return false};_,err:=time.Parse("2006-01-02",d);return err==nil}
func render(s State, mode, date string) string {
 var items []Task
 for _,t:=range s.tasks {
  if mode=="today" && (t.date!=date||t.done) {continue}
  if mode=="deadline" && t.date=="-" {continue}
  items=append(items,t)
 }
 switch mode {
 case "project":
  ranks:=map[string]int{};for i,p:=range s.projects {ranks[p]=i}
  sort.Slice(items,func(i,j int)bool {a,b:=items[i],items[j];if ranks[a.project]!=ranks[b.project]{return ranks[a.project]<ranks[b.project]};return a.ordinal<b.ordinal})
 case "today":sort.Slice(items,func(i,j int)bool{a,b:=items[i],items[j];if a.project!=b.project{return a.project<b.project};return a.id<b.id})
 case "deadline":sort.Slice(items,func(i,j int)bool{a,b:=items[i],items[j];if a.date!=b.date{return a.date<b.date};return a.id<b.id})
 case "date":sort.Slice(items,func(i,j int)bool{a,b:=items[i],items[j];if (a.date=="-")!=(b.date=="-"){return a.date!="-"};if a.date!=b.date{return a.date<b.date};return a.id<b.id})
 }
 out:=make([]string,len(items));for i,t:=range items {v:=0;if t.done{v=1};out[i]=fmt.Sprintf("%s@%s@%s@%s@%d",t.id,t.project,t.title,t.date,v)}
 return "LIST:"+strings.Join(out,";")
}
func interpret(script string) string {
 var history []Event
 var outputs []string
 for _,line:=range strings.Split(script,"\n") {
  if line=="" {continue}
  f:=strings.Split(line,"|"); op:=f[0];s:=fold(history)
  response:="OK";accepted:=false
  switch op {
  case "project":
   if len(f)!=2 {response="ERR:arity"} else if !projectRe.MatchString(f[1]) {response="ERR:project"} else if hasProject(s,f[1]){response="ERR:duplicate-project"}else{accepted=true}
  case "add":
   if len(f)!=4{response="ERR:arity"}else if !projectRe.MatchString(f[1]){response="ERR:project"}else if !idRe.MatchString(f[2]){response="ERR:id"}else if strings.TrimSpace(f[3])==""||strings.ContainsAny(f[3],";@|"){response="ERR:title"}else if !hasProject(s,f[1]){response="ERR:missing-project"}else if _,ok:=s.tasks[f[2]];ok{response="ERR:duplicate-id"}else{accepted=true}
  case "done","delete":
   if len(f)!=2{response="ERR:arity"}else if !idRe.MatchString(f[1]){response="ERR:id"}else if _,ok:=s.tasks[f[1]];!ok{response="ERR:missing-task"}else{accepted=true}
  case "deadline":
   if len(f)!=3{response="ERR:arity"}else if !idRe.MatchString(f[1]){response="ERR:id"}else if !dateValid(f[2]){response="ERR:date"}else if _,ok:=s.tasks[f[1]];!ok{response="ERR:missing-task"}else{accepted=true}
  case "today":
   if len(f)!=2{response="ERR:arity"}else if !dateValid(f[1]){response="ERR:date"}else{response=render(s,"today",f[1])}
  case "view":
   if len(f)!=2{response="ERR:arity"}else if f[1]!="project"&&f[1]!="deadline"&&f[1]!="date"{response="ERR:view"}else{response=render(s,f[1],"")}
  default:response="ERR:command"
  }
  if accepted {history=append(history,Event{op:op,f:f})}
  outputs=append(outputs,response)
 }
 return strings.Join(outputs,"\n")
}
func main(){
 if len(os.Args)!=2{panic("usage: oracle <Kotlin runnable jar>")}
 r:=rand.New(rand.NewSource(2602026))
 var scripts []string
 var renamePairs [][2]int
 // Explicit witness: deletion must not corrupt creation order.
 scripts=append(scripts,"project|Work\nadd|Work|A|Alpha\nadd|Work|B|Beta\nadd|Work|C|Gamma\ndelete|A\ndelete|B\nadd|Work|D|Delta\nview|project")
 for i:=0;i<500;i++ {
  lines:=[]string{"project|Work","project|Home"}
  for j:=0;j<28;j++ {
   id:=fmt.Sprintf("T%d",r.Intn(13)); project:="Work";if r.Intn(2)==0{project="Home"}
   date:="2026-11-01";if r.Intn(2)==0{date="2026-11-02"}
   switch r.Intn(9){
   case 0,1,2:lines=append(lines,fmt.Sprintf("add|%s|%s|Title%d",project,id,j))
   case 3:lines=append(lines,"done|"+id)
   case 4:lines=append(lines,"delete|"+id)
   case 5:lines=append(lines,"deadline|"+id+"|"+date)
   case 6:lines=append(lines,"today|"+date)
   case 7:lines=append(lines,"view|deadline")
   case 8:lines=append(lines,"view|project","view|date")
   }
  }
  scripts=append(scripts,strings.Join(lines,"\n"))
 }
 // Metamorphic transformation: rename every project consistently and verify again.
 for i:=0;i<200;i++ {original:=1+r.Intn(500);s:=scripts[original];s=strings.ReplaceAll(s,"Work","Office");s=strings.ReplaceAll(s,"Home","House");renamePairs=append(renamePairs,[2]int{original,len(scripts)});scripts=append(scripts,s)}
 var input bytes.Buffer
 for _,s:=range scripts{input.WriteString(base64.StdEncoding.EncodeToString([]byte(s))+"\n")}
 cmd:=exec.Command("java","-jar",os.Args[1]);cmd.Stdin=&input
 out,err:=cmd.Output();if err!=nil{panic(fmt.Sprintf("Kotlin failed %v",err))}
 scanner:=bufio.NewScanner(bytes.NewReader(out));scanner.Buffer(make([]byte,4096),4*1024*1024)
 count:=0
 var actual []string
 for scanner.Scan(){if count>=len(scripts){panic("extra result")};decoded,err:=base64.StdEncoding.DecodeString(scanner.Text());if err!=nil{panic(err)};want:=interpret(scripts[count]);got:=string(decoded);actual=append(actual,got);if got!=want{fmt.Fprintf(os.Stderr,"FAIL scenario %d\nSCRIPT:\n%s\nWANT:\n%s\nGOT:\n%s\n",count,scripts[count],want,got);os.Exit(1)};count++}
 if err:=scanner.Err();err!=nil{panic(err)}
 if count!=len(scripts){panic("missing results")}
 for _,pair:=range renamePairs {want:=strings.ReplaceAll(actual[pair[0]],"Work","Office");want=strings.ReplaceAll(want,"Home","House");if actual[pair[1]]!=want{panic(fmt.Sprintf("metamorphic project rename failed %d -> %d",pair[0],pair[1]))}}
 fmt.Printf("GO event-replay oracle: %d Kotlin scenarios PASS (1 deletion witness, 500 generated, 200 renamed)\n",count)
}
