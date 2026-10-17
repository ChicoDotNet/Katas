//go:build !kata_red
// SPDX-License-Identifier: MIT
package dominoes

import "fmt"

// Tile is an unoriented edge in an undirected multigraph.
type Tile struct { A int `json:"a"`; B int `json:"b"` }
type Result struct { Possible bool `json:"possible"`; Chain []Tile `json:"chain"` }

// Solve constructs a closed Euler walk and uses each physical tile exactly once.
func Solve(tiles []Tile) (Result,error) {
    for _,t:=range tiles {if t.A<0||t.B<0{return Result{},fmt.Errorf("negative pip")}}
    if len(tiles)==0{return Result{Possible:true,Chain:[]Tile{}},nil}
    degree:=map[int]int{}
    adj:=map[int][]int{}
    for i,t:=range tiles {
        degree[t.A]++;degree[t.B]++
        adj[t.A]=append(adj[t.A],i);adj[t.B]=append(adj[t.B],i)
    }
    for _,d:=range degree{if d%2!=0{return Result{Chain:[]Tile{}},nil}}
    start:=tiles[0].A
    reached:=map[int]bool{start:true};queue:=[]int{start}
    for len(queue)>0 {
        v:=queue[0];queue=queue[1:]
        for _,edge:=range adj[v] {
            t:=tiles[edge];w:=t.A;if w==v{w=t.B}
            if !reached[w]{reached[w]=true;queue=append(queue,w)}
        }
    }
    if len(reached)!=len(degree){return Result{Chain:[]Tile{}},nil}
    used:=make([]bool,len(tiles));cursor:=make(map[int]int,len(degree))
    stack:=[]int{start};reverse:=make([]int,0,len(tiles)+1)
    for len(stack)>0 {
        v:=stack[len(stack)-1];edges:=adj[v]
        for cursor[v]<len(edges)&&used[edges[cursor[v]]]{cursor[v]++}
        if cursor[v]==len(edges){reverse=append(reverse,v);stack=stack[:len(stack)-1];continue}
        edge:=edges[cursor[v]];cursor[v]++
        if used[edge]{continue}
        used[edge]=true;t:=tiles[edge];w:=t.A;if w==v{w=t.B}
        stack=append(stack,w)
    }
    if len(reverse)!=len(tiles)+1{return Result{Chain:[]Tile{}},nil}
    chain:=make([]Tile,0,len(tiles))
    for i:=len(reverse)-1;i>0;i--{chain=append(chain,Tile{A:reverse[i],B:reverse[i-1]})}
    return Result{Possible:true,Chain:chain},nil
}
