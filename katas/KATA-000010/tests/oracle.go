// Independent event-history oracle for the original BugsZero anti-bug contract.
// It does not maintain the Ada implementation's mutable position/score/deck indexes.
package main

import (
    "bytes"
    "fmt"
    "math/rand"
    "os"
    "os/exec"
    "strconv"
    "strings"
)

type turn struct { roll, answer int }
type scenario struct {
    players, cats, cells int
    ids, board, decks []int
    turns []turn
}

func input(s scenario) string {
    var b strings.Builder
    fmt.Fprintf(&b, "%d %d %d %d\n", s.players, s.cats, s.cells, len(s.turns))
    for _, a := range [][]int{s.ids, s.board, s.decks} {
        for _, x := range a { fmt.Fprintf(&b, "%d ", x) }
        b.WriteByte('\n')
    }
    for _, t := range s.turns { fmt.Fprintf(&b, "%d %d\n", t.roll, t.answer) }
    return b.String()
}

func execute(binary string, s scenario) (string, error) {
    cmd := exec.Command(binary)
    cmd.Stdin = strings.NewReader(input(s))
    var out, stderr bytes.Buffer
    cmd.Stdout, cmd.Stderr = &out, &stderr
    err := cmd.Run()
    if err != nil { return out.String(), fmt.Errorf("%w: %s", err, stderr.String()) }
    return out.String(), nil
}

func visitCategory(s scenario, index int) int {
    p := index % s.players
    total := 0
    for j := 0; j <= index; j++ {
        if j % s.players == p { total += s.turns[j].roll }
    }
    return s.board[total % s.cells]
}

// Calculate a snapshot from the entire immutable event history for every output.
func expected(s scenario) string {
    var b strings.Builder
    for i := range s.turns {
        p := i % s.players
        category := visitCategory(s, i)
        visits := 0
        for j := 0; j < i; j++ {
            if visitCategory(s, j) == category { visits++ }
        }
        question := 1 + visits % s.decks[category-1]
        score, penalized := 0, false
        for j := 0; j <= i; j++ {
            if j % s.players != p { continue }
            if s.turns[j].answer == 0 { penalized = true
            } else if penalized { penalized = false
            } else { score++ }
        }
        jailed := 0
        if penalized { jailed = 1 }
        fmt.Fprintf(&b, "%d %d %d %d %d\n", p+1, category, question, score, jailed)
    }
    return b.String()
}

func normalize(s string) string {
    lines := strings.Split(strings.TrimSpace(s), "\n")
    if strings.TrimSpace(s) == "" { return "" }
    for i, l := range lines { lines[i] = strings.Join(strings.Fields(l), " ") }
    return strings.Join(lines, "\n")
}

func assert(binary string, s scenario, label string) {
    got, err := execute(binary, s)
    if err != nil { panic(fmt.Sprintf("%s unexpectedly rejected: %v\nINPUT:\n%s", label, err, input(s))) }
    want := expected(s)
    if normalize(got) != normalize(want) {
        panic(fmt.Sprintf("%s mismatch\nINPUT:\n%s\nGOT:\n%s\nWANT:\n%s", label, input(s), got, want))
    }
}

func invalid(binary string, s scenario, label string) {
    _, err := execute(binary, s)
    if err == nil { panic("invalid input accepted: " + label + "\n" + input(s)) }
}

func main() {
    if len(os.Args) != 2 { panic("usage: oracle <ada-cli>") }
    binary := os.Args[1]
    rng := rand.New(rand.NewSource(20261102))
    total, steps, metamorphic := 0, 0, 0
    for n := 0; n < 300; n++ {
        p, c, cells := 2+rng.Intn(5), 1+rng.Intn(4), 1+rng.Intn(17)
        s := scenario{players:p, cats:c, cells:cells}
        for i:=0; i<p; i++ { s.ids = append(s.ids, 10+i) }
        for i:=0; i<cells; i++ { s.board = append(s.board, 1+rng.Intn(c)) }
        for i:=0; i<c; i++ { s.decks = append(s.decks, 1+rng.Intn(5)) }
        for i:=0; i<1+rng.Intn(40); i++ { s.turns = append(s.turns, turn{1+rng.Intn(6),rng.Intn(2)}) }
        assert(binary,s,"generated-"+strconv.Itoa(n)); total++;steps+=len(s.turns)
        // Renaming players cannot alter index-based game traces.
        renamed := s
        renamed.ids = append([]int(nil),s.ids...)
        for i:=range renamed.ids { renamed.ids[i] = 90-i }
        assert(binary,renamed,"renamed-"+strconv.Itoa(n));metamorphic++
        // Reassigning category labels bijectively preserves scores/penalties,
        // while the independently recomputed oracle checks relabeled question streams.
        if c>1 {
            perm := s
            perm.board = append([]int(nil),s.board...)
            perm.decks = append([]int(nil),s.decks...)
            for i,x:=range perm.board { perm.board[i] = c+1-x }
            for i,x:=range s.decks { perm.decks[c-1-i] = x }
            assert(binary,perm,"category-permutation-"+strconv.Itoa(n));metamorphic++
        }
    }
    base:=scenario{players:2,cats:2,cells:3,ids:[]int{11,22},board:[]int{1,2,1},decks:[]int{2,1},turns:[]turn{{1,1},{1,0},{2,1},{2,1},{3,1}}}
    assert(binary,base,"fixed-regression");total++
    x:=base;x.players=1;invalid(binary,x,"one player")
    x=base;x.players=7;invalid(binary,x,"seven players")
    x=base;x.ids=[]int{11,11};invalid(binary,x,"duplicate players")
    x=base;x.board=[]int{1,3,1};invalid(binary,x,"unknown category")
    x=base;x.decks=[]int{0,1};invalid(binary,x,"empty deck")
    x=base;x.cells=0;invalid(binary,x,"empty board")
    x=base;x.turns=[]turn{{0,1}};invalid(binary,x,"zero roll")
    x=base;x.turns=[]turn{{1,2}};invalid(binary,x,"invalid answer")
    fmt.Printf("GO EVENT-HISTORY ORACLE PASS: %d baseline scenarios, %d turns, %d metamorphic sessions, 8 invalid configurations\n",total,steps,metamorphic)
}
