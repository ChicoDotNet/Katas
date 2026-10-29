// Independent coordinate-compression oracle for original MIT Christmas Lights kata.
// Unlike the Fortran dense-cell updater, this models weighted disjoint rectangles.
package main

import (
 "bytes"
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "sort"
 "strconv"
 "strings"
)

type command struct { op, x1, y1, x2, y2 int }
type result struct { lit, bright int64 }

func uniqueSorted(xs []int) []int {
 sort.Ints(xs)
 out:=make([]int,0,len(xs))
 for _,x:=range xs { if len(out)==0 || out[len(out)-1]!=x { out=append(out,x) } }
 return out
}

// Oracle partitions the entire board into rectangular cells whose boundaries
// coincide with command edges, then weights each representative by cell area.
func expected(n int, cmds []command) result {
 xs,ys:=[]int{0,n},[]int{0,n}
 for _,c:=range cmds {xs=append(xs,c.x1,c.x2+1);ys=append(ys,c.y1,c.y2+1)}
 xs,ys=uniqueSorted(xs),uniqueSorted(ys)
 var total result
 for i:=0;i<len(xs)-1;i++ {for j:=0;j<len(ys)-1;j++ {
  x,y:=xs[i],ys[j]
  lit,bright:=false,int64(0)
  for _,c:=range cmds { if c.x1<=x && x<=c.x2 && c.y1<=y && y<=c.y2 {
   switch c.op {case 1:lit=true;bright++
    case 2:lit=false;if bright>0 {bright--}
    case 3:lit=!lit;bright+=2}
  }}
  area:=int64(xs[i+1]-x)*int64(ys[j+1]-y)
  if lit {total.lit+=area}
  total.bright+=bright*area
 }}
 return total
}

func runCLI(binary string,n int,cmds []command) (result,error) {
 var input strings.Builder
 fmt.Fprintf(&input,"%d %d\n",n,len(cmds))
 for _,c:=range cmds {fmt.Fprintf(&input,"%d %d %d %d %d\n",c.op,c.x1,c.y1,c.x2,c.y2)}
 cmd:=exec.Command(binary)
 cmd.Stdin=strings.NewReader(input.String())
 out,err:=cmd.CombinedOutput()
 if err!=nil{return result{},fmt.Errorf("cli: %w output=%q",err,string(out))}
 fields:=bytes.Fields(out)
 if len(fields)!=2{return result{},fmt.Errorf("unexpected output: %q",out)}
 a,e:=strconv.ParseInt(string(fields[0]),10,64);if e!=nil{return result{},e}
 b,e:=strconv.ParseInt(string(fields[1]),10,64);if e!=nil{return result{},e}
 return result{a,b},nil
}

func same(binary string,n int,cmds []command) error {
 want:=expected(n,cmds)
 got,err:=runCLI(binary,n,cmds)
 if err!=nil{return err}
 if got!=want {return fmt.Errorf("n=%d commands=%v expected=%v actual=%v",n,cmds,want,got)}
 return nil
}

func randomCmd(r *rand.Rand,n int) command {
 a,b,c,d:=r.Intn(n),r.Intn(n),r.Intn(n),r.Intn(n)
 if a>c {a,c=c,a};if b>d {b,d=d,b}
 return command{r.Intn(3)+1,a,b,c,d}
}

func verify(binary string,quick bool) (int,error) {
 checks:=0
 // Exhaust all 1x1 instruction sequences up to length 6, including empty.
 maxDepth:=6;if quick {maxDepth=4}
 var walk func([]command,int)error
 walk=func(cs []command,depth int)error {
  if err:=same(binary,1,cs);err!=nil{return err};checks++
  if depth==maxDepth{return nil}
  for op:=1;op<=3;op++ {next:=append(append([]command{},cs...),command{op,0,0,0,0});if err:=walk(next,depth+1);err!=nil{return err}}
  return nil
 }
 if err:=walk(nil,0);err!=nil{return checks,err}
 r:=rand.New(rand.NewSource(20261029))
 samples:=500;if quick {samples=75}
 for z:=0;z<samples;z++ {
  n:=1+r.Intn(32);count:=r.Intn(28)
  cs:=make([]command,count)
  for i:=range cs {cs[i]=randomCmd(r,n)}
  if err:=same(binary,n,cs);err!=nil{return checks,err};checks++
 }
 // Large real-world board; the oracle never allocates 1,000,000 cells.
 large:=[]command{{1,0,0,999,999},{3,0,0,999,0},{2,499,499,500,500},{3,100,200,800,900}}
 if err:=same(binary,1000,large);err!=nil{return checks,err};checks++
 // Metamorphism: splitting an inclusive rectangle into two disjoint pieces
 // preserves all observable effects, even with a nonempty prior history.
 metamorphic:=120;if quick {metamorphic=15}
 for z:=0;z<metamorphic;z++ {
  n:=2+r.Intn(25)
  prefix:=[]command{randomCmd(r,n),randomCmd(r,n)}
  c:=randomCmd(r,n)
  if c.x1==c.x2 {c.x1=0;c.x2=n-1}
  mid:=(c.x1+c.x2)/2
  original:=append(append([]command{},prefix...),c)
  split:=append(append([]command{},prefix...),command{c.op,c.x1,c.y1,mid,c.y2},command{c.op,mid+1,c.y1,c.x2,c.y2})
  if err:=same(binary,n,original);err!=nil{return checks,err};checks++
  if err:=same(binary,n,split);err!=nil{return checks,err};checks++
  a,err:=runCLI(binary,n,original);if err!=nil{return checks,err}
  b,err:=runCLI(binary,n,split);if err!=nil{return checks,err}
  if a!=b || expected(n,original)!=expected(n,split) {return checks,fmt.Errorf("split metamorphism failed")}
  checks++
 }
 // Commutativity of nonoverlapping rectangles, for all operations.
 for z:=0;z<40;z++ {
  n:=4+r.Intn(20);half:=n/2
  a:=command{1+r.Intn(3),0,0,half-1,n-1}
  b:=command{1+r.Intn(3),half,0,n-1,n-1}
  first,second:=[]command{a,b},[]command{b,a}
  if err:=same(binary,n,first);err!=nil{return checks,err};checks++
  if err:=same(binary,n,second);err!=nil{return checks,err};checks++
  x,_:=runCLI(binary,n,first);y,_:=runCLI(binary,n,second)
  if x!=y {return checks,fmt.Errorf("disjoint operations failed to commute")}
  checks++
 }
 return checks,nil
}

func main(){
 if len(os.Args)<2 {fmt.Fprintln(os.Stderr,"usage: oracle <Fortran CLI> [--quick]");os.Exit(2)}
 quick:=len(os.Args)>2 && os.Args[2]=="--quick"
 n,err:=verify(os.Args[1],quick)
 if err!=nil {fmt.Fprintf(os.Stderr,"ORACLE FAIL after %d comparisons: %v\n",n,err);os.Exit(1)}
 fmt.Printf("ORACLE PASS %d comparisons (coordinate compression, exhaustive, random, metamorphic)\n",n)
}
