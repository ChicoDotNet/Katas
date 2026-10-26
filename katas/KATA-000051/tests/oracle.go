package main

import (
 "fmt"
 "math/rand"
 "os"
 "os/exec"
 "strconv"
 "strings"
)

// Reference A: closed-form ring index, not a translation of the Fortran
// shrinking-boundary walker. All coordinates are zero-based.
func cell(n, r, c int) int64 {
 k:=r
 for _,v:=range []int{c,n-1-r,n-1-c} {if v<k {k=v}}
 side:=n-2*k
 start:=int64(1+4*k*(n-k))
 if side==1 {return start}
 end:=n-1-k
 switch {
 case r==k: return start+int64(c-k)
 case c==end: return start+int64(side-1+r-k)
 case r==end: return start+int64(2*(side-1)+end-c)
 default: return start+int64(3*(side-1)+end-r)
 }
}
func formula(n int) [][]int64 {
 a:=make([][]int64,n)
 for r:=range a {a[r]=make([]int64,n);for c:=range a[r] {a[r][c]=cell(n,r,c)}}
 return a
}
func parse(out []byte,n int) ([][]int64,error) {
 if n==0 {if len(out)>0{return nil,fmt.Errorf("nonempty output for n=0: %q",out)};return [][]int64{},nil}
 lines:=strings.Split(strings.TrimSuffix(string(out),"\n"),"\n")
 if len(lines)!=n {return nil,fmt.Errorf("expected %d rows, got %d",n,len(lines))}
 a:=make([][]int64,n)
 for r,line:=range lines {
  fields:=strings.Fields(line)
  if len(fields)!=n{return nil,fmt.Errorf("row %d expected %d columns got %d",r,n,len(fields))}
  a[r]=make([]int64,n)
  for c,s:=range fields {v,err:=strconv.ParseInt(s,10,64);if err!=nil{return nil,err};a[r][c]=v}
 }
 return a,nil
}
func execute(path string,n int) ([][]int64,error) {
 cmd:=exec.Command(path,strconv.Itoa(n))
 out,err:=cmd.CombinedOutput()
 if err!=nil{return nil,fmt.Errorf("n=%d execution: %w %s",n,err,out)}
 return parse(out,n)
}
func verify(n int,got [][]int64) error {
 want:=formula(n)
 seen:=make(map[int64]bool,n*n)
 for r:=0;r<n;r++ {for c:=0;c<n;c++ {
  v:=got[r][c]
  if v!=want[r][c] {return fmt.Errorf("n=%d r=%d c=%d want %d got %d",n,r,c,want[r][c],v)}
  if v<1||v>int64(n*n)||seen[v] {return fmt.Errorf("n=%d non-permutation value %d",n,v)}
  seen[v]=true
 }}
 return nil
}
// Metamorphic oracle B does not calculate expected cell values at all:
// it compares outputs of two *separate* Fortran executions (n and n-2).
func verifyPeel(n int, got, inner [][]int64) error {
 if n<3 {return nil}
 shift:=int64(4*(n-1))
 for r:=1;r<n-1;r++ {for c:=1;c<n-1;c++ {
  if got[r][c]-shift!=inner[r-1][c-1] {return fmt.Errorf("metamorphic ring peel n=%d r=%d c=%d",n,r,c)}
 }}
 return nil
}
func main() {
 if len(os.Args)!=2 {panic("usage: go run tests/oracle.go PATH_TO_FORTRAN_CLI")}
 path,err:=os.Stat(os.Args[1]);if err!=nil||path.IsDir(){panic("Fortran executable missing")}
 rng:=rand.New(rand.NewSource(20261026))
 sizes:=[]int{0,1,2,3,4,5,6,7,8,9,10,11,16,17,31,32,33,63,64,65}
 for i:=0;i<250;i++ {sizes=append(sizes,rng.Intn(70))}
 checked:=0
 for _,n:=range sizes {
  got,e:=execute(os.Args[1],n);if e!=nil{panic(e)}
  if e=verify(n,got);e!=nil{panic(e)}
  if n>=3 {
   inner,err:=execute(os.Args[1],n-2);if err!=nil{panic(err)}
   if err=verifyPeel(n,got,inner);err!=nil{panic(err)}
  }
  checked++
 }
 for _,n:=range []int{-1,513} {
  cmd:=exec.Command(os.Args[1],strconv.Itoa(n))
  if err:=cmd.Run();err==nil{panic(fmt.Sprintf("invalid n=%d accepted",n))}
 }
 fmt.Printf("PASS Go closed-form ring reference + permutation + ring-peel metamorphism: %d sizes, 2 invalid-size rejections\n",checked)
}
