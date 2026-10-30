// Independent AST-first oracle: the expected value comes from generated integer
// leaves, never from parsing the serialized input sent to Swift.
package main

import (
 "bufio"
 "bytes"
 "encoding/base64"
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "strconv"
 "strings"
)

type Case struct { input, expected, label string }
var cases []Case

func add(input, expected, label string) { cases=append(cases, Case{input,expected,label}) }
func expectedFor(nums []int64) string {
 var neg []string
 var sum int64
 for _, n:=range nums {
  if n<0 {neg=append(neg,strconv.FormatInt(n,10))} else if n<=1000 {sum+=n}
 }
 if len(neg)>0 {return "ERR|negative|"+base64.StdEncoding.EncodeToString([]byte("negatives not allowed: "+strings.Join(neg,",")))}
 return "OK|"+strconv.FormatInt(sum,10)
}
func serialize(nums []int64, mode int, r *rand.Rand) string {
 var header string
 var delims []string
 switch mode {
 case 0: delims=[]string{",","\n"}
 case 1: header="//;\n"; delims=[]string{";"}
 case 2: header="//[***]\n"; delims=[]string{"***"}
 case 3: header="//[**][*]\n"; delims=[]string{"**","*"}
 case 4: header="//[ab][a]\n"; delims=[]string{"ab","a"}
 case 5: header="//[🦊][🐺]\n"; delims=[]string{"🦊","🐺"}
 case 6: header="//[🔬🔬][+]\n"; delims=[]string{"🔬🔬","+"}
 default: panic("mode")
 }
 var b strings.Builder
 b.WriteString(header)
 for i,n:=range nums {
  if i>0 {b.WriteString(delims[r.Intn(len(delims))])}
  b.WriteString(strconv.FormatInt(n,10))
 }
 return b.String()
}
func main(){
 if len(os.Args)!=2 {panic("usage: oracle executable")}
 r:=rand.New(rand.NewSource(2502026))
 values:=[]int64{-4,-1,0,1,1000,1001,1999}
 // Exhaustive fixed-length AST histories, with overlapping and Unicode delimiters.
 for a:=0;a<len(values);a++ {for b:=0;b<len(values);b++ {for c:=0;c<len(values);c++ {
  nums:=[]int64{values[a],values[b],values[c]}
  mode:=(a*49+b*7+c)%7
  add(serialize(nums,mode,r),expectedFor(nums),"exhaustive")
 }}}
 for i:=0;i<1800;i++ {
  n:=1+r.Intn(13)
  nums:=make([]int64,n)
  for j:=range nums { nums[j]=int64(r.Intn(2600)-90) }
  mode:=r.Intn(7)
  add(serialize(nums,mode,r),expectedFor(nums),"generated")
 }
 // Metamorphic: reorder nonnegative AST leaves, and change delimiter grammar.
 for i:=0;i<400;i++ {
  n:=2+r.Intn(15)
  nums:=make([]int64,n)
  for j:=range nums {nums[j]=int64(r.Intn(2001))}
  mode:=r.Intn(7)
  add(serialize(nums,mode,r),expectedFor(nums),"metamorphic-original")
  r.Shuffle(len(nums),func(a,b int){nums[a],nums[b]=nums[b],nums[a]})
  add(serialize(nums,(mode+1)%7,r),expectedFor(nums),"metamorphic-permute-and-relabel")
 }
 // Hand-designed malformed grammar checks; native tests also cover these.
 add("1,", "ERR|empty|"+base64.StdEncoding.EncodeToString([]byte("number expected")), "trailing")
 add("//[x]z\n1x2", "ERR|header|"+base64.StdEncoding.EncodeToString([]byte("invalid delimiter header")), "header")
 add("//;\n1,2", "ERR|number|"+base64.StdEncoding.EncodeToString([]byte("invalid number: 1,2")), "custom-default-disallowed")
 add("999999999999999999999999999,2", "OK|2", "large-positive-ignored")
 add("-999999999999999999999999999", "ERR|overflow|"+base64.StdEncoding.EncodeToString([]byte("integer overflow")), "large-negative-rejected")
 var stdin bytes.Buffer
 for _,c:=range cases {stdin.WriteString(base64.StdEncoding.EncodeToString([]byte(c.input))+"\n")}
 cmd:=exec.Command(os.Args[1]); cmd.Stdin=&stdin
 out,err:=cmd.Output();if err!=nil {panic(fmt.Sprintf("Swift process failed: %v",err))}
 scanner:=bufio.NewScanner(bytes.NewReader(out)); scanner.Buffer(make([]byte,4096),1024*1024)
 count:=0
 for scanner.Scan(){
  if count>=len(cases){panic("unexpected extra output")}
  got:=scanner.Text();c:=cases[count]
  if got!=c.expected {fmt.Fprintf(os.Stderr,"FAIL case %d (%s) input=%q\nexpected %s\ngot %s\n",count,c.label,c.input,c.expected,got);os.Exit(1)}
  count++
 }
 if err:=scanner.Err();err!=nil {panic(err)}
 if count!=len(cases){panic(fmt.Sprintf("missing responses %d/%d",count,len(cases)))}
 fmt.Printf("GO AST-first oracle: %d Swift executions PASS (343 exhaustive, 1800 generated, 800 metamorphic, 5 malformed)\n",count)
}
