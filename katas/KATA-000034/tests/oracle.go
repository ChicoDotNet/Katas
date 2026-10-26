// Independent exhaustive model: permutations of each category, pruned only
// after its own clues become decidable. It does not use CLP(FD) or Prolog.
package main

import (
    "fmt"
    "os"
    "os/exec"
    "strings"
)

func permutations() [][5]int {
    result := make([][5]int, 0, 120)
    var visit func([5]int, int)
    visit = func(a [5]int, i int) {
        if i == len(a) { result = append(result, a); return }
        for j := i; j < len(a); j++ {
            a[i], a[j] = a[j], a[i]
            visit(a, i+1)
            a[i], a[j] = a[j], a[i]
        }
    }
    visit([5]int{0, 1, 2, 3, 4}, 0)
    return result
}

func near(a, b int) bool { return a+1 == b || b+1 == a }

// Positions are zero-based; each property appears once per category.
type world struct { colors, nations, drinks, pets, hobbies [5]int }

func independentWorlds() []world {
    ps := permutations()
    found := make([]world, 0, 2)
    for _, c := range ps { // red, green, ivory, yellow, blue
        if c[4] != 1 || c[1] != c[2]+1 { continue }
        for _, n := range ps { // english, spanish, ukrainian, norwegian, japanese
            if n[3] != 0 || n[0] != c[0] { continue }
            for _, d := range ps { // coffee, tea, milk, orange, water
                if d[2] != 2 || d[0] != c[1] || d[1] != n[2] { continue }
                for _, h := range ps { // dancing, painting, reading, football, chess
                    if h[1] != c[3] || h[3] != d[3] || h[4] != n[4] { continue }
                    for _, p := range ps { // dog, snails, fox, horse, zebra
                        if p[0] != n[1] || p[1] != h[0] || !near(p[2], h[2]) || !near(p[3], h[1]) { continue }
                        found = append(found, world{c, n, d, p, h})
                    }
                }
            }
        }
    }
    return found
}

func independentSolutions() [][2]string {
    names := [5]string{"englishman", "spaniard", "ukrainian", "norwegian", "japanese"}
    answers := make([][2]string, 0, 2)
    for _, w := range independentWorlds() {
        water, zebra := "", ""
        for i, pos := range w.nations {
            if pos == w.drinks[4] { water = names[i] }
            if pos == w.pets[4] { zebra = names[i] }
        }
        answers = append(answers, [2]string{water, zebra})
    }
    return answers
}

func worldSignature(w world) string {
    group := func(a [5]int) string {
        return fmt.Sprintf("[%d,%d,%d,%d,%d]", a[0]+1, a[1]+1, a[2]+1, a[3]+1, a[4]+1)
    }
    return strings.Join([]string{group(w.colors), group(w.nations), group(w.drinks), group(w.pets), group(w.hobbies)}, "|")
}

func main() {
    expected := independentSolutions()
    if len(expected) != 1 { fmt.Fprintf(os.Stderr, "independent model found %d layouts, want exactly one\n", len(expected)); os.Exit(1) }
    fmt.Printf("Go exhaustive permutation oracle: unique assignment; water=%s zebra=%s\n", expected[0][0], expected[0][1])
    if len(os.Args) == 1 { return }
    cmd := exec.Command("swipl", "-q", "-s", "src/zebra.pl", "-g", "zebra:solution(W,Z),format('~w,~w~n',[W,Z])", "-t", "halt")
    cmd.Dir = os.Args[1]
    output, err := cmd.CombinedOutput()
    if err != nil { fmt.Fprintf(os.Stderr, "Prolog runtime failed: %v: %s\n", err, output); os.Exit(1) }
    actual := strings.TrimSpace(string(output))
    want := expected[0][0] + "," + expected[0][1]
    if actual != want { fmt.Fprintf(os.Stderr, "differential mismatch: got %q want %q\n", actual, want); os.Exit(1) }
    layoutCmd := exec.Command("swipl", "-q", "-s", "src/zebra.pl", "-g", "zebra:layout(houses(C,N,D,P,H)),format('~w|~w|~w|~w|~w~n',[C,N,D,P,H])", "-t", "halt")
    layoutCmd.Dir = os.Args[1]
    layoutOutput, layoutErr := layoutCmd.CombinedOutput()
    if layoutErr != nil { fmt.Fprintf(os.Stderr, "Prolog layout failed: %v: %s\n", layoutErr, layoutOutput); os.Exit(1) }
    actualLayout := strings.TrimSpace(string(layoutOutput))
    expectedLayout := worldSignature(independentWorlds()[0])
    if actualLayout != expectedLayout { fmt.Fprintf(os.Stderr, "full-world mismatch: got %q want %q\n", actualLayout, expectedLayout); os.Exit(1) }
    fmt.Println("Differential Prolog/Go: PASS (answers and all 25 positions)")
}
