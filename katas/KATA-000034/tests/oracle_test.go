package main

import "testing"

func TestUniqueSolution(t *testing.T) {
    got := independentSolutions()
    if len(got) != 1 { t.Fatalf("expected one assignment, got %d", len(got)) }
    if got[0] != [2]string{"norwegian", "japanese"} { t.Fatalf("unexpected answer %v", got[0]) }
}

func TestPermutationCoverage(t *testing.T) {
    ps := permutations()
    if len(ps) != 120 { t.Fatalf("expected 120, got %d", len(ps)) }
    seen := map[[5]int]bool{}
    for _, p := range ps {
        if seen[p] { t.Fatalf("duplicate permutation %v", p) }
        seen[p] = true
    }
}
