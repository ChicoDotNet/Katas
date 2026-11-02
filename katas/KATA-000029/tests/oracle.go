package main

// Independent reachability oracle: enumerate all LEGAL histories from the
// empty board and stop expanding immediately on a win. Java uses direct
// parity/winner constraints on an arbitrary board, not game-tree search.

import (
    "bufio"
    "bytes"
    "fmt"
    "os"
    "os/exec"
    "strconv"
    "strings"
)

func winner(b string) byte {
    for i := 0; i < 3; i++ {
        if b[3*i] != '.' && b[3*i] == b[3*i+1] && b[3*i+1] == b[3*i+2] { return b[3*i] }
        if b[i] != '.' && b[i] == b[i+3] && b[i+3] == b[i+6] { return b[i] }
    }
    if b[4] != '.' && ((b[0] == b[4] && b[4] == b[8]) || (b[2] == b[4] && b[4] == b[6])) { return b[4] }
    return '.'
}

func reachable() map[string]string {
    start := "........."
    seen := map[string]string{}
    queue := []string{start}
    for len(queue) > 0 {
        b := queue[0]; queue = queue[1:]
        if _, exists := seen[b]; exists { continue }
        if w := winner(b); w != '.' {
            seen[b] = "WIN:" + string(w)
            continue
        }
        if !strings.ContainsRune(b, '.') {
            seen[b] = "DRAW"
            continue
        }
        count := 0
        for _, c := range b { if c != '.' { count++ } }
        mark := byte('X')
        if count%2 == 1 { mark = 'O' }
        positions := make([]string, 0, 9-count)
        for i := 0; i < 9; i++ {
            if b[i] != '.' { continue }
            positions = append(positions, strconv.Itoa(i))
            next := []byte(b); next[i] = mark
            queue = append(queue, string(next))
        }
        seen[b] = "NEXT:" + string(mark) + "|MOVES:" + strings.Join(positions, ",")
    }
    return seen
}

func allBoards() []string {
    boards := make([]string, 0, 19683)
    for n := 0; n < 19683; n++ {
        digits := n
        b := make([]byte, 9)
        for i := 0; i < 9; i++ {
            b[i] = ".XO"[digits%3]
            digits /= 3
        }
        boards = append(boards, string(b))
    }
    return boards
}

// A dihedral transform of a 3x3 board, generated independently of Java.
func transform(b string, reflection bool, turns int) string {
    result := make([]byte, 9)
    for i := 0; i < 9; i++ {
        row, col := i/3, i%3
        if reflection { col = 2-col }
        for j := 0; j < turns; j++ { row, col = col, 2-row }
        result[3*row+col] = b[i]
    }
    return string(result)
}

func main() {
    if len(os.Args) != 2 { panic("usage: go run oracle.go <compiled-java-classpath>") }
    states := reachable()
    boards := allBoards()
    cases := append([]string{}, boards...)
    metamorphic := 0
    // A reproducible sample across the entire state space, not only examples.
    for i := 0; i < len(boards); i += 39 {
        b := boards[i]
        for f := 0; f < 2; f++ {
            for t := 0; t < 4; t++ {
                mapped := transform(b, f == 1, t)
                // Independently check that reachability is invariant.
                _, before := states[b]
                _, after := states[mapped]
                if before != after { panic("symmetry reachability violation") }
                cases = append(cases, mapped)
                metamorphic++
            }
        }
    }
    invalid := []string{"", "X", ".........X", "XOXOXOXO?", "x........", "💻........", "XXXXXXXXX", "O........O"}
    cases = append(cases, invalid...)
    cmd := exec.Command("java", "-cp", os.Args[1], "Main")
    var input bytes.Buffer
    for _, b := range cases { input.WriteString(b); input.WriteByte('\n') }
    cmd.Stdin = &input
    out, err := cmd.Output()
    if err != nil { panic(fmt.Sprintf("Java CLI failed: %v", err)) }
    scan := bufio.NewScanner(bytes.NewReader(out))
    for i, b := range cases {
        if !scan.Scan() { panic(fmt.Sprintf("missing Java response at %d", i)) }
        want, found := states[b]
        if !found { want = "ERR:unreachable" }
        for _, invalidBoard := range invalid {
            if b == invalidBoard {
                if len(b) != 9 || strings.ContainsAny(b, "?x💻") { want = "ERR:format" }
                break
            }
        }
        got := scan.Text()
        if got != want { panic(fmt.Sprintf("differential #%d board=%q got=%q want=%q", i, b, got, want)) }
    }
    if scan.Scan() { panic("unexpected extra Java response") }
    if err := scan.Err(); err != nil { panic(err) }
    fmt.Printf("GO BFS ORACLE PASS: %d reachable states; %d ternary boards; %d dihedral metamorphic cases; %d malformed/adversarial; %d total CLI cases\n", len(states), len(boards), metamorphic, len(invalid), len(cases))
}
