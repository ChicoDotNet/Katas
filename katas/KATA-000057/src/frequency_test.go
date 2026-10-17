// SPDX-License-Identifier: MIT
package frequency
import("reflect";"testing")
func must(t *testing.T,lines []string,workers int,want map[rune]int){
 t.Helper();got,err:=Count(lines,workers)
 if err!=nil||!reflect.DeepEqual(got,want){t.Fatalf("FAIL behavioral assertion: expected %v got %v error %v",want,got,err)}
}
func TestCounts(t *testing.T){
 must(t,[]string{"Hello","world!"},4,map[rune]int{'h':1,'e':1,'l':3,'o':2,'w':1,'r':1,'d':1})
 must(t,[]string{"AaA","bbb","123 !"},1,map[rune]int{'a':3,'b':3})
 must(t,[]string{},8,map[rune]int{})
 must(t,[]string{"","",""},32,map[rune]int{})
 must(t,[]string{"École","é!"},2,map[rune]int{'é':2,'c':1,'o':1,'l':1,'e':1})
 must(t,[]string{"Σσ","Жж"},2,map[rune]int{'σ':2,'ж':2})
}
func TestValidation(t *testing.T){for _,n:=range []int{0,-1,33}{if _,err:=Count([]string{"a"},n);err==nil{t.Fatalf("invalid workers %d accepted",n)}}}
func TestParallelMatchesSequential(t *testing.T){
 lines:=[]string{"Hello!","éÉëê","Go😀!","HELLO","ΣσЖж",""}
 expected,err:=Count(lines,1);if err!=nil{t.Fatal(err)}
 for n:=2;n<=32;n++{got,err:=Count(lines,n);if err!=nil||!reflect.DeepEqual(got,expected){t.Fatalf("non deterministic worker %d",n)}}
}
