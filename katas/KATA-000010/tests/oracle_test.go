package main

import "testing"

func TestIndependentHistoryReference(t *testing.T) {
    s := scenario{players:2,cats:2,cells:3,
        ids:[]int{11,22},board:[]int{1,2,1},decks:[]int{2,1},
        turns:[]turn{{1,1},{1,0},{2,1},{2,1},{3,1}}}
    want := "1 2 1 1 0\n2 2 1 0 1\n1 1 1 2 0\n2 1 2 0 0\n1 1 1 3 0"
    if got := normalize(expected(s)); got != want {
        t.Fatalf("reference history mismatch:\n%s\nwant:\n%s",got,want)
    }
}

func TestDeckCyclesAndBoardWrapping(t *testing.T) {
    s := scenario{players:2,cats:1,cells:1,
        ids:[]int{11,22},board:[]int{1},decks:[]int{2},
        turns:[]turn{{6,1},{1,1},{3,1},{2,1}}}
    want := "1 1 1 1 0\n2 1 2 1 0\n1 1 1 2 0\n2 1 2 2 0"
    if got := normalize(expected(s)); got != want {
        t.Fatalf("deck wrap mismatch:\n%s",got)
    }
}
