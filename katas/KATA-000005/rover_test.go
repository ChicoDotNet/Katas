package rover
import "testing"
func check(t *testing.T,got Result,x,y int,dir string,applied int,stopped bool){
 t.Helper()
 if got.Pose!=(Pose{X:x,Y:y,Facing:dir}) || got.Applied!=applied || got.Blocked!=stopped {
  t.Fatalf("wrong pose or stop: got=%+v expected x=%d y=%d facing=%s applied=%d blocked=%t",got,x,y,dir,applied,stopped)
 }
}
func TestNavigation(t *testing.T){
 w:=World{Width:5,Height:4}
 start:=Pose{X:0,Y:0,Facing:"N"}
 r,e:=Navigate(w,start,"ffrfflb");if e!=nil{t.Fatal(e)};check(t,r,2,1,"N",7,false)
 r,e=Navigate(w,start,"lfrf");if e!=nil{t.Fatal(e)};check(t,r,4,1,"N",4,false)
 r,e=Navigate(w,start,"b");if e!=nil{t.Fatal(e)};check(t,r,0,3,"N",1,false)
 r,e=Navigate(w,start,"llll");if e!=nil{t.Fatal(e)};check(t,r,0,0,"N",4,false)
 r,e=Navigate(w,start,"");if e!=nil{t.Fatal(e)};check(t,r,0,0,"N",0,false)
}
func TestObstaclesAbortBeforeEntry(t *testing.T){
 w:=World{Width:4,Height:4,Obstacles:[]Point{{X:0,Y:2}}}
 r,e:=Navigate(w,Pose{X:0,Y:0,Facing:"N"},"ffrff");if e!=nil{t.Fatal(e)}
 check(t,r,0,1,"N",1,true)
 if r.Obstacle==nil || *r.Obstacle!=(Point{X:0,Y:2}){t.Fatalf("wrong obstacle report: %+v",r)}
}
func TestValidateCommandsBeforeMovement(t *testing.T){
 _,e:=Navigate(World{Width:4,Height:4},Pose{X:0,Y:0,Facing:"N"},"ffx")
 if e==nil{t.Fatal("unknown commands must be rejected atomically before any movement")}
}
func TestBadWorldOrOrientation(t *testing.T){
 for _,tc:=range []struct{w World;p Pose}{
 {World{},Pose{Facing:"N"}},
 {World{Width:3,Height:3},Pose{X:3,Facing:"N"}},
 {World{Width:3,Height:3},Pose{Facing:"Q"}},
 {World{Width:3,Height:3,Obstacles:[]Point{{X:5}}},Pose{Facing:"N"}},
 }{if _,e:=Navigate(tc.w,tc.p,"f");e==nil{t.Fatalf("must reject invalid state: %+v",tc)}}
}
