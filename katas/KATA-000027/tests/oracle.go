// SPDX-License-Identifier: MIT
// Independent arithmetic-prefix reference for a finite-state Ruby game.
// Exhaustively enumerates histories, including illegal post-win suffixes.
package main

import (
	"bytes"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"strings"
)

var word = []string{"Love", "Fifteen", "Thirty", "Forty"}

func reference(seq string) string {
	a, b := 0, 0
	for _, c := range seq {
		if a >= 4 && a-b >= 2 || b >= 4 && b-a >= 2 {
			return "ERR:finished"
		}
		if c == 'A' {
			a++
		} else if c == 'B' {
			b++
		} else {
			return "ERR:invalid"
		}
	}
	if a >= 4 && a-b >= 2 {
		return "Win A"
	}
	if b >= 4 && b-a >= 2 {
		return "Win B"
	}
	if a >= 3 && b >= 3 {
		if a == b {
			return "Deuce"
		}
		if a > b {
			return "Advantage A"
		}
		return "Advantage B"
	}
	if a == b {
		return word[a] + "-All"
	}
	return word[a] + "-" + word[b]
}

func swap(seq string) string {
	var b strings.Builder
	for _, c := range seq {
		if c == 'A' {
			b.WriteByte('B')
		} else if c == 'B' {
			b.WriteByte('A')
		} else {
			b.WriteRune(c)
		}
	}
	return b.String()
}
func swapScore(s string) string {
	if s == "ERR:finished" || s == "ERR:invalid" || s == "Deuce" || strings.HasSuffix(s, "-All") {
		return s
	}
	if s == "Win A" {
		return "Win B"
	}
	if s == "Win B" {
		return "Win A"
	}
	if s == "Advantage A" {
		return "Advantage B"
	}
	if s == "Advantage B" {
		return "Advantage A"
	}
	p := strings.Split(s, "-")
	return p[1] + "-" + p[0]
}
func main() {
	if len(os.Args) < 2 {
		panic("usage: go run tests/oracle.go src/cli.rb")
	}
	sequences := make([]string, 0, 35000)
	sequences = append(sequences, "")
	for n := 1; n <= 14; n++ {
		for mask := 0; mask < (1 << n); mask++ {
			var b strings.Builder
			for j := n - 1; j >= 0; j-- {
				if mask&(1<<j) == 0 {
					b.WriteByte('A')
				} else {
					b.WriteByte('B')
				}
			}
			sequences = append(sequences, b.String())
		}
	}
	rng := rand.New(rand.NewSource(27030))
	for i := 0; i < 1000; i++ {
		n := rng.Intn(42)
		var b strings.Builder
		for j := 0; j < n; j++ {
			if rng.Intn(2) == 0 {
				b.WriteByte('A')
			} else {
				b.WriteByte('B')
			}
		}
		sequences = append(sequences, b.String())
	}
	// Validate input errors and terminal-precedence errors independently.
	sequences = append(sequences, "C", "AAC", "AAAAZ", "ZAAAA", "AAABBBABAAZ")
	// Metamorphic pairs are additional actual Ruby executions.
	original := len(sequences)
	for i := 0; i < 1000; i++ {
		sequences = append(sequences, swap(sequences[rng.Intn(original)]))
	}
	var input strings.Builder
	for _, seq := range sequences {
		if seq == "" {
			input.WriteString("-\n")
		} else {
			input.WriteString(seq + "\n")
		}
	}
	cmd := exec.Command("ruby", os.Args[1])
	cmd.Stdin = strings.NewReader(input.String())
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	output, err := cmd.Output()
	if err != nil {
		fmt.Fprintln(os.Stderr, stderr.String())
		panic(err)
	}
	lines := strings.Split(strings.TrimSuffix(string(output), "\n"), "\n")
	if len(lines) != len(sequences) {
		panic(fmt.Sprintf("Ruby produced %d lines, expected %d", len(lines), len(sequences)))
	}
	for i, seq := range sequences {
		expected := reference(seq)
		if lines[i] != expected {
			panic(fmt.Sprintf("oracle mismatch #%d seq=%q got=%q expected=%q", i, seq, lines[i], expected))
		}
	}
	// Swap metamorphism compares actual Ruby outputs for paired histories.
	observed := make(map[string]string, len(sequences))
	for i, seq := range sequences {
		observed[seq] = lines[i]
	}
	metamorphic := 0
	for _, seq := range sequences[:original] {
		paired := swap(seq)
		if other, ok := observed[paired]; ok {
			if other != swapScore(observed[seq]) {
				panic(fmt.Sprintf("swap metamorphism failed %q", seq))
			}
			metamorphic++
		}
	}
	fmt.Printf("GO independent count/prefix oracle PASS: %d Ruby histories, %d observed player-swap metamorphic pairs (exhaustive through 14 points; 1000 seeded generated)\n", len(sequences), metamorphic)
}
