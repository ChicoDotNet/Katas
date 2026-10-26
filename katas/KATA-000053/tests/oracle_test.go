package main
import (
 "reflect"
 "testing"
)
func TestGeneratorAndAdjacency(t *testing.T) {
 for n:=1;n<=70;n++ {
  tree:=generate(n,uint64(n)*33)
  adj:=adjacency(tree)
  if len(adj)!=n {t.Fatalf("size %d: %d labels",n,len(adj))}
  sum:=0;for u,neighbors:=range adj {sum+=len(neighbors);for _,v:=range neighbors {found:=false;for _,back:=range adj[v] {if back==u {found=true}};if !found {t.Fatalf("asymmetric %s-%s",u,v)}}}
  if sum!=2*(n-1) {t.Fatalf("size %d: edges %d",n,sum/2)}
 }
}
func TestBFSPathAndOrientation(t *testing.T) {
 tree:=Tree{Label:"r",Children:[]Tree{{Label:"a",Children:[]Tree{{Label:"c"}}},{Label:"b"}}}
 adj:=adjacency(tree)
 if got:=bfsPath(adj,"c","b");!reflect.DeepEqual(got,[]string{"c","a","r","b"}) {t.Fatalf("got %v",got)}
 expected,ok:=rootedNeighbors(adj,"c")
 if !ok||!reflect.DeepEqual(expected["c"],[]string{"a"})||!reflect.DeepEqual(expected["a"],[]string{"r"}) {t.Fatalf("bad orientation %v",expected)}
 if got:=bfsPath(adj,"c","missing");got!=nil {t.Fatalf("missing node: %v",got)}
}
