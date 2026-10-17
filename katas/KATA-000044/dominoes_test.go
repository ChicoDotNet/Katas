package dominoes
import("testing";"reflect")
func valid(input,chain []Tile)bool{
 if len(input)!=len(chain){return false}
 freq:=map[Tile]int{}
 canonical:=func(t Tile)Tile{if t.A>t.B{t.A,t.B=t.B,t.A};return t}
 for _,t:=range input{freq[canonical(t)]++}
 for i,t:=range chain{if i>0&&chain[i-1].B!=t.A{return false};freq[canonical(t)]--}
 if len(chain)>0&&chain[0].A!=chain[len(chain)-1].B{return false}
 for _,n:=range freq{if n!=0{return false}}
 return true
}
func TestClosedChains(t *testing.T){
 cases:=[]struct{name string;tiles []Tile;yes bool}{
 {"empty",nil,true},{"loop",[]Tile{{2,2}},true},{"single edge",[]Tile{{1,2}},false},
 {"triangle",[]Tile{{1,2},{3,1},{2,3}},true},
 {"reversible triangle",[]Tile{{1,2},{1,3},{2,3}},true},
 {"parallel edges",[]Tile{{1,2},{1,2}},true},
 {"disconnected loops",[]Tile{{1,1},{2,2}},false},
 {"disconnected cycles",[]Tile{{1,2},{2,3},{3,1},{4,5},{5,6},{6,4}},false},
 {"bridge cycles",[]Tile{{1,2},{2,3},{3,1},{2,4},{2,4}},true},
 {"all self loops",[]Tile{{7,7},{7,7},{7,7}},true},
 }
 for _,tt:=range cases{t.Run(tt.name,func(t *testing.T){got,err:=Solve(tt.tiles);if err!=nil||got.Possible!=tt.yes{t.Fatalf("wrong possibility: %+v err %v",got,err)};if got.Possible&&!valid(tt.tiles,got.Chain){t.Fatalf("invalid chain: %+v",got.Chain)}})}
}
func TestInvalidAndImmutableInput(t *testing.T){
 if _,err:=Solve([]Tile{{-1,1}});err==nil{t.Fatal("negative pip not rejected")}
 tiles:=[]Tile{{2,1},{2,1}};prior:=append([]Tile(nil),tiles...)
 _,_ = Solve(tiles);if !reflect.DeepEqual(tiles,prior){t.Fatal("input mutated")}
}
