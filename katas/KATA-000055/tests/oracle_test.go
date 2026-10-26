package main
import "testing"
func TestStablePartition(t *testing.T){
 got:=expectedPreorder([]int{3,3,4,2,-7})
 want:="3 3 2 -7 # # # # 4 # #"
 if got!=want{t.Fatalf("got %s",got)}
}
