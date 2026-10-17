//go:build kata_red
// SPDX-License-Identifier: MIT
package dominoes
import "fmt"
type Tile struct{ A int `json:"a"`;B int `json:"b"` }
type Result struct{ Possible bool `json:"possible"`;Chain []Tile `json:"chain"` }
func Solve(tiles []Tile)(Result,error){for _,t:=range tiles{if t.A<0||t.B<0{return Result{},fmt.Errorf("negative pip")}};return Result{Possible:true,Chain:[]Tile{}},nil}
