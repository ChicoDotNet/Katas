package main
import "testing"
func TestRingReference(t *testing.T) {
 want:=[][]int64{{1,2,3,4},{12,13,14,5},{11,16,15,6},{10,9,8,7}}
 got:=formula(4)
 for r:=range want {for c:=range want[r] {if got[r][c]!=want[r][c] {t.Fatalf("r=%d c=%d want=%d got=%d",r,c,want[r][c],got[r][c])}}}
}
func TestSingleAndEmpty(t *testing.T) {
 if len(formula(0))!=0 {t.Fatal("n=0")}
 if formula(1)[0][0]!=1 {t.Fatal("n=1")}
}
func TestRingPeelFormula(t *testing.T) {
 for n:=3;n<=65;n++ {a:=formula(n);b:=formula(n-2);delta:=int64(4*(n-1));for r:=1;r<n-1;r++ {for c:=1;c<n-1;c++ {if a[r][c]!=b[r-1][c-1]+delta {t.Fatalf("n=%d r=%d c=%d",n,r,c)}}}}
}
func TestParseRejectsMalformed(t *testing.T) {
 if _,err:=parse([]byte("1 2\n3\n"),2);err==nil{t.Fatal("ragged matrix accepted")}
 if _,err:=parse([]byte("1 2\n3 x\n"),2);err==nil{t.Fatal("nonnumeric matrix accepted")}
 if _,err:=parse([]byte("1\n"),0);err==nil{t.Fatal("nonempty n=0 accepted")}
}
