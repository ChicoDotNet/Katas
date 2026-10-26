// KATA-000055 Go reference: stable recursive partition, not pointer insertion.
// ChicoDotNet 2026, MIT; no external fixtures copied.
package main
import (
 "bufio"
 "fmt"
 "io"
 "math/rand"
 "os"
 "os/exec"
 "sort"
 "strconv"
 "strings"
)
func expectedPreorder(a []int) string {
 if len(a)==0{return "#"}
 root:=a[0]
 var left,right []int
 for _,v:=range a[1:] {if v<=root {left=append(left,v)}else{right=append(right,v)}}
 return strconv.Itoa(root)+" "+expectedPreorder(left)+" "+expectedPreorder(right)
}
func ints(a []int)string {s:=make([]string,len(a));for i,v:=range a{s[i]=strconv.Itoa(v)};return strings.Join(s," ")}
func run(bin string)error{
 cmd:=exec.Command(bin)
 stdin,e:=cmd.StdinPipe();if e!=nil{return e}
 stdout,e:=cmd.StdoutPipe();if e!=nil{return e}
 cmd.Stderr=os.Stderr
 if e=cmd.Start();e!=nil{return e}
 defer func(){_ = stdin.Close();_ = cmd.Process.Kill();_ = cmd.Wait()}()
 reader:=bufio.NewReader(stdout)
 rng:=rand.New(rand.NewSource(0x551b))
 cases:=[][]int{{},{3},{3,3},{3,3,4,2,-7},{-2147483648,2147483647,0,0}}
 for i:=0;i<350;i++{
  n:=rng.Intn(100)
  a:=make([]int,n)
  for j:=range a {a[j]=rng.Intn(131)-65}
  cases=append(cases,a)
 }
 for ci,a:=range cases{
  line:=strconv.Itoa(len(a));if len(a)>0{line+=" "+ints(a)}
  if _,e=io.WriteString(stdin,line+"\n");e!=nil{return e}
  p,e:=reader.ReadString('\n');if e!=nil{return fmt.Errorf("case %d preorder EOF: %w",ci,e)}
  sorted,e:=reader.ReadString('\n');if e!=nil{return fmt.Errorf("case %d inorder EOF: %w",ci,e)}
  if strings.TrimSuffix(p,"\n")!=expectedPreorder(a){return fmt.Errorf("case %d structural mismatch: got %q expected %q",ci,strings.TrimSpace(p),expectedPreorder(a))}
  want:=append([]int(nil),a...);sort.Ints(want)
  if strings.TrimSuffix(sorted,"\n")!=ints(want){return fmt.Errorf("case %d sorted mismatch: got %q want %q",ci,strings.TrimSpace(sorted),ints(want))}
  // Metamorphic: reordering insertion input may change shape but must preserve the in-order multiset.
  shuffled:=append([]int(nil),a...)
  rng.Shuffle(len(shuffled),func(i,j int){shuffled[i],shuffled[j]=shuffled[j],shuffled[i]})
  query:=strconv.Itoa(len(shuffled));if len(shuffled)>0{query+=" "+ints(shuffled)}
  if _,e=io.WriteString(stdin,query+"\n");e!=nil{return e}
  shuffledPre,e:=reader.ReadString('\n');if e!=nil{return fmt.Errorf("shuffled case %d preorder EOF: %w",ci,e)}
  shuffledIn,e:=reader.ReadString('\n');if e!=nil{return fmt.Errorf("shuffled case %d inorder EOF: %w",ci,e)}
  if strings.TrimSuffix(shuffledIn,"\n")!=strings.TrimSuffix(sorted,"\n"){return fmt.Errorf("case %d metamorphic inorder mismatch",ci)}
  if strings.TrimSuffix(shuffledPre,"\n")!=expectedPreorder(shuffled){return fmt.Errorf("case %d shuffled shape mismatch",ci)}
 }
 fmt.Printf("Go stable-partition + sorted multiset + input permutation oracle: %d original and %d permuted cases PASS\n",len(cases),len(cases))
 return nil
}
func main(){if len(os.Args)!=2{fmt.Fprintln(os.Stderr,"usage: go run oracle.go /path/to/bst-cli");os.Exit(2)};if e:=run(os.Args[1]);e!=nil{fmt.Fprintln(os.Stderr,e);os.Exit(1)}}
