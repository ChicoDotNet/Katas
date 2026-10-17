package lift
import("reflect";"testing")
func steps(e *Engine,n int)[]Event{v:=make([]Event,0,n);for i:=0;i<n;i++{v=append(v,e.Tick())};return v}
func TestPickupAndDelivery(t *testing.T){
 e,_:=New(5,0);_ = e.Call(2,4)
 want:=[]Event{{1,"move"},{2,"pickup"},{3,"move"},{4,"dropoff"}}
 if got:=steps(e,4);!reflect.DeepEqual(got,want){t.Fatalf("unexpected trace: %v != %v",got,want)}
 if e.Pending(){t.Fatal("delivered request remains pending")}
}
func TestFIFOAndSameFloor(t *testing.T){
 e,_:=New(5,0);_ = e.Call(0,2);_ = e.Call(1,0)
 want:=[]Event{{0,"pickup"},{1,"move"},{2,"dropoff"},{1,"pickup"},{0,"dropoff"}}
 if got:=steps(e,5);!reflect.DeepEqual(got,want){t.Fatalf("FIFO trace: %v",got)}
 e,_=New(5,3);_ = e.Call(3,3)
 same:=[]Event{{3,"pickup"},{3,"dropoff"}}
 if got:=steps(e,2);!reflect.DeepEqual(got,same){t.Fatalf("same floor trace: %v",got)}
}
func TestIdleAndValidation(t *testing.T){
 e,_:=New(3,1);if got:=e.Tick();got!=(Event{1,"idle"}){t.Fatal(got)}
 if err:=e.Call(-1,1);err==nil{t.Fatal("negative floor should fail")}
 if err:=e.Call(1,4);err==nil{t.Fatal("floor above max should fail")}
 if e.Pending(){t.Fatal("invalid call queued")}
 if _,err:=New(0,1);err==nil{t.Fatal("initial outside building")}
}
