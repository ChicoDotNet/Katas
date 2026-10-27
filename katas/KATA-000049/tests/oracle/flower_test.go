package floweroracle

import (
 "bytes"
 "context"
 "time"
 "fmt"
 "math/rand"
 "os/exec"
 "strings"
 "testing"
)

// A summed-area table answers each 3x3 flower query using four prefix sums.
// This differs from the Fortran implementation's 3x3 array stencil.
func prefixOracle(in []string) []string {
 rows := len(in)
 if rows == 0 { return []string{} }
 cols := len(in[0])
 prefix := make([][]int, rows+1)
 for r:=range prefix { prefix[r]=make([]int,cols+1) }
 for r:=0;r<rows;r++ { for c:=0;c<cols;c++ {
  x:=0; if in[r][c]=='*' { x=1 }
  prefix[r+1][c+1]=x+prefix[r][c+1]+prefix[r+1][c]-prefix[r][c]
 }}
 out:=make([]string,rows)
 for r:=0;r<rows;r++ {
  line:=[]byte(in[r])
  for c:=0;c<cols;c++ {
   if line[c]=='*' { continue }
   loR,hiR:=max(0,r-1),min(rows-1,r+1)
   loC,hiC:=max(0,c-1),min(cols-1,c+1)
   count:=prefix[hiR+1][hiC+1]-prefix[loR][hiC+1]-prefix[hiR+1][loC]+prefix[loR][loC]
   if count>0 { line[c]=byte('0'+count) }
  }
  out[r]=string(line)
 }
 return out
}

func runNative(in []string) ([]string,error) {
 rows:=len(in); cols:=0; if rows>0 {cols=len(in[0])}
 var b strings.Builder
 fmt.Fprintf(&b,"%d %d\n",rows,cols)
 for _,row:=range in { fmt.Fprintln(&b,row) }
 ctx,cancel:=context.WithTimeout(context.Background(),5*time.Second)
 defer cancel()
 cmd:=exec.CommandContext(ctx,"../../build/flower-field")
 cmd.Stdin=strings.NewReader(b.String())
 var stderr bytes.Buffer
 cmd.Stderr=&stderr
 raw,err:=cmd.Output()
 if err!=nil { return nil,fmt.Errorf("native exit: %w rows=%d cols=%d stderr=%s",err,rows,cols,stderr.String()) }
 if rows==0 { if len(raw)!=0 {return nil,fmt.Errorf("unexpected output for empty board")};return []string{},nil }
 lines:=strings.Split(strings.TrimSuffix(string(raw),"\n"),"\n")
 if len(lines)!=rows { return nil,fmt.Errorf("got %d rows, want %d: %q",len(lines),rows,raw) }
 for _,line:=range lines { if len(line)!=cols {return nil,fmt.Errorf("bad row width %d want %d",len(line),cols)} }
 return lines,nil
}
func rotate(in []string) []string {
 if len(in)==0 {return []string{}}
 rows,cols:=len(in),len(in[0]);out:=make([]string,cols)
 for c:=0;c<cols;c++ {var b strings.Builder;for r:=rows-1;r>=0;r-- {b.WriteByte(in[r][c])};out[c]=b.String()}
 return out
}
func reflect(in []string) []string {
 out:=make([]string,len(in))
 for r,row:=range in {b:=[]byte(row);for i,j:=0,len(b)-1;i<j;i,j=i+1,j-1 {b[i],b[j]=b[j],b[i]};out[r]=string(b)}
 return out
}
func same(a,b []string) bool { if len(a)!=len(b) {return false};for i:=range a {if a[i]!=b[i] {return false}};return true }

func TestIndependentPrefixAndMetamorphisms(t *testing.T) {
 rng:=rand.New(rand.NewSource(490049))
 const histories=240
 for n:=0;n<histories;n++ {
  rows,cols:=rng.Intn(26),rng.Intn(26)
  if n%9==0 {rows=0;cols=0}
  in:=make([]string,rows)
  density:=rng.Intn(101)
  for r:=0;r<rows;r++ {var b strings.Builder;for c:=0;c<cols;c++ {if rng.Intn(100)<density {b.WriteByte('*')} else {b.WriteByte('.')}};in[r]=b.String()}
  actual,err:=runNative(in);if err!=nil {t.Fatalf("case=%d: %v",n,err)}
  want:=prefixOracle(in)
  if !same(actual,want) {t.Fatalf("case=%d input=%q got=%q want=%q",n,in,actual,want)}
  if rows==0 || cols==0 {continue}
  turned,err:=runNative(rotate(in));if err!=nil {t.Fatalf("rotated case=%d: %v",n,err)}
  if !same(turned,rotate(actual)) {t.Fatalf("rotation case=%d",n)}
  mirrored,err:=runNative(reflect(in));if err!=nil {t.Fatalf("reflected case=%d: %v",n,err)}
  if !same(mirrored,reflect(actual)) {t.Fatalf("reflection case=%d",n)}
 }
 t.Logf("PASS %d independent prefix cases; real-process rotation/reflection",histories)
}
func TestMalformedInputRejected(t *testing.T) {
 inputs:=[]string{"1 3\n*.\n","1 2\n*X\n","-1 0\n","513 1\n","1 1\n","1 2\n**X\n"}
 for _,input:=range inputs {
  cmd:=exec.Command("../../build/flower-field");cmd.Stdin=strings.NewReader(input)
  if err:=cmd.Run();err==nil {t.Errorf("accepted malformed input %q",input)}
 }
}

func TestLargeAndDegenerate(t *testing.T) {
 for _,shape:=range [][2]int{{1,512},{512,1},{128,128},{256,256}} {
  rows,cols:=shape[0],shape[1]
  board:=make([]string,rows)
  for r:=0;r<rows;r++ {var b strings.Builder;for c:=0;c<cols;c++ {if (r*19+c*23)%7<3 {b.WriteByte('*')} else {b.WriteByte('.')}};board[r]=b.String()}
  actual,err:=runNative(board);if err!=nil {t.Fatalf("shape %v: %v",shape,err)}
  if !same(actual,prefixOracle(board)) {t.Fatalf("shape %v mismatch",shape)}
 }
}
