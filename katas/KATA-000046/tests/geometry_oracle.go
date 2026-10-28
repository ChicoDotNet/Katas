// SPDX-License-Identifier: MIT
// Independent constructive/metamorphic oracle: geometry is transformed,
// rather than reimplementing the Swift word-search enumeration.
package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "math/rand"
    "os"
    "os/exec"
    "strings"
)

type point struct { R, C int }
type testCase struct { Grid []string `json:"grid"`; Words []string `json:"words"` }
type match struct { Word string `json:"word"`; Start []int `json:"start"`; End []int `json:"end"` }
type scenario struct { Group, Transform int; Unique bool; Start, End point }
type direction struct { DR, DC int }

var dirs = []direction{{-1,0},{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1},{-1,-1}}

func mapped(t int, p point, h, w int) point {
    switch t {
    case 0: return p
    case 1: return point{p.C, h-1-p.R} // clockwise 90
    case 2: return point{h-1-p.R, w-1-p.C}
    case 3: return point{w-1-p.C, p.R}
    case 4: return point{p.R, w-1-p.C} // horizontal reflection
    case 5: return point{h-1-p.R, p.C} // vertical reflection
    case 6: return point{p.C, p.R} // transpose
    case 7: return point{w-1-p.C, h-1-p.R} // anti-transpose
    default: panic("unknown transform")
    }
}

func transform(grid []string, t int) []string {
    h,w := len(grid),len(grid[0]); nh,nw:=h,w
    if t==1||t==3||t==6||t==7 {nh,nw=w,h}
    out:=make([][]byte,nh)
    for i:=range out {out[i]=make([]byte,nw)}
    for r:=0;r<h;r++ {for c:=0;c<w;c++ {
        p:=mapped(t,point{r,c},h,w);out[p.R][p.C]=grid[r][c]
    }}
    lines:=make([]string,nh)
    for i:=range out {lines[i]=string(out[i])}
    return lines
}

func planted(rng *rand.Rand) (testCase,point,point) {
    h,w:=2+rng.Intn(12),2+rng.Intn(12)
    var start point;var d direction;maxLen:=0
    for maxLen<2 {
        start=point{rng.Intn(h),rng.Intn(w)};d=dirs[rng.Intn(len(dirs))]
        maxLen=0
        for r,c:=start.R,start.C;r>=0&&r<h&&c>=0&&c<w;r,c=r+d.DR,c+d.DC {maxLen++}
    }
    n:=2+rng.Intn(min(10,maxLen)-1)
    rows:=make([][]byte,h)
    for r:=range rows {rows[r]=bytes.Repeat([]byte{'A'},w)}
    for k:=0;k<n;k++ {rows[start.R+k*d.DR][start.C+k*d.DC]=byte('B'+k)}
    lines:=make([]string,h)
    for r:=range rows {lines[r]=string(rows[r])}
    word:="BCDEFGHIJK"[:n]
    reverse:=[]byte(word)
    for i,j:=0,len(reverse)-1;i<j;i,j=i+1,j-1 {reverse[i],reverse[j]=reverse[j],reverse[i]}
    end:=point{start.R+(n-1)*d.DR,start.C+(n-1)*d.DC}
    return testCase{lines,[]string{word,string(reverse),"ZZZ","AA","A"}},start,end
}

func randomBoard(rng *rand.Rand) testCase {
    h,w:=1+rng.Intn(12),1+rng.Intn(12)
    rows:=make([]string,h)
    for r:=range rows {var b strings.Builder;for c:=0;c<w;c++ {b.WriteByte(byte('A'+rng.Intn(5)))};rows[r]=b.String()}
    words:=[]string{"AA","ABA","ABCDE","ZZZ","A","B","C","D"}
    for k:=0;k<4;k++ {var b strings.Builder;for j:=0;j<2+rng.Intn(7);j++ {b.WriteByte(byte('A'+rng.Intn(5)))};words=append(words,b.String())}
    return testCase{rows,words}
}

func validateWitness(grid []string, m match) error {
    if len(m.Start)==0 && len(m.End)==0 {return nil}
    if len(m.Start)!=2 || len(m.End)!=2 {return fmt.Errorf("partial coordinates: %+v",m)}
    h,w:=len(grid),len(grid[0]);r,c:=m.Start[0],m.Start[1];er,ec:=m.End[0],m.End[1]
    if r<0||r>=h||c<0||c>=w||er<0||er>=h||ec<0||ec>=w {return fmt.Errorf("out-of-range witness %+v",m)}
    n:=len(m.Word)
    dr,dc:=er-r,ec-c
    if n==1 {if dr!=0||dc!=0 {return fmt.Errorf("single-character displacement %+v",m)}} else {
        if dr%(n-1)!=0||dc%(n-1)!=0 {return fmt.Errorf("non-integral displacement %+v",m)}
        dr/=n-1;dc/=n-1
        if dr < -1||dr>1||dc < -1||dc>1||(dr==0&&dc==0) {return fmt.Errorf("not a straight 8-way path %+v",m)}
    }
    for k:=0;k<n;k++ {if grid[r+k*dr][c+k*dc]!=m.Word[k] {return fmt.Errorf("false witness %+v",m)}}
    return nil
}

func equalPoint(p []int, q point) bool {return len(p)==2&&p[0]==q.R&&p[1]==q.C}
func fail(format string,args ...any) {fmt.Fprintf(os.Stderr,"FAIL geometry oracle: "+format+"\n",args...);os.Exit(1)}

func main() {
    if len(os.Args)!=2 {fail("usage: geometry_oracle <swift-cli>")}
    // Self-check group identities before trusting coordinate transforms.
    sample:=[]string{"ABC","DEF"}
    same:=func(a,b []string) bool {return strings.Join(a,"|")==strings.Join(b,"|")}
    if !same(transform(transform(sample,1),3),sample) ||
       !same(transform(transform(sample,4),4),sample) ||
       !same(transform(transform(sample,6),6),sample) ||
       !same(transform(transform(transform(transform(sample,1),1),1),1),sample) {
        fail("geometry transform group identity failed")
    }
    rng:=rand.New(rand.NewSource(20261028))
    cases:=make([]testCase,0,1760);meta:=make([]scenario,0,1760)
    const plantedCount=180;const randomCount=40
    for group:=0;group<plantedCount+randomCount;group++ {
        var base testCase;var start,end point
        unique:=group<plantedCount
        if unique {base,start,end=planted(rng)} else {base=randomBoard(rng)}
        for t:=0;t<8;t++ {
            cases=append(cases,testCase{transform(base.Grid,t),base.Words})
            meta=append(meta,scenario{group,t,unique,start,end})
        }
    }
    input,err:=json.Marshal(cases);if err!=nil {fail("marshal: %v",err)}
    cmd:=exec.Command(os.Args[1]);cmd.Stdin=bytes.NewReader(input)
    output,err:=cmd.CombinedOutput();if err!=nil {fail("Swift CLI: %v: %s",err,output)}
    var got [][]match
    if err:=json.Unmarshal(output,&got);err!=nil {fail("decode Swift output: %v: %s",err,output[:min(200,len(output))])}
    if len(got)!=len(cases) {fail("expected %d cases, got %d",len(cases),len(got))}
    witnesses:=0;invariants:=0;uniqueChecks:=0
    for i,result:=range got {
        c:=cases[i];m:=meta[i]
        if len(result)!=len(c.Words) {fail("case %d result length",i)}
        for j,x:=range result {
            if x.Word!=c.Words[j] {fail("case %d word %d mismatch",i,j)}
            if err:=validateWitness(c.Grid,x);err!=nil {fail("case %d: %v",i,err)}
            if len(x.Start)==2 {witnesses++}
            // The eight symmetries preserve word existence, NOT deterministic tie-break.
            baseline:=got[m.Group*8][j]
            if (len(x.Start)==2)!=(len(baseline.Start)==2) {fail("existence changed under transform case=%d word=%s",i,x.Word)}
            invariants++
        }
        if m.Unique {
            h,w:=len(cases[m.Group*8].Grid),len(cases[m.Group*8].Grid[0])
            start:=mapped(m.Transform,m.Start,h,w);end:=mapped(m.Transform,m.End,h,w)
            if !equalPoint(result[0].Start,start)||!equalPoint(result[0].End,end) {fail("planted witness transform=%d group=%d: %+v expected %+v..%+v",m.Transform,m.Group,result[0],start,end)}
            if !equalPoint(result[1].Start,end)||!equalPoint(result[1].End,start) {fail("reverse witness transform=%d group=%d: %+v",m.Transform,m.Group,result[1])}
            if len(result[2].Start)!=0||len(result[2].End)!=0 {fail("impossible ZZZ found at case %d",i)}
            uniqueChecks+=3
        }
    }
    fmt.Printf("PASS: %d boards, %d symmetry existence invariants, %d constructive witness/absence checks, %d valid witnesses\n",len(cases),invariants,uniqueChecks,witnesses)
}
