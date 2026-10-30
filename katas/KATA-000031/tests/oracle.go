// SPDX-License-Identifier: MIT
// Brute-force index subsets, not the implementation's face histogram.
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

type Dice [5]int

func equalGroup(d Dice, mask int) bool {
	val := 0
	for i := 0; i < 5; i++ {
		if mask&(1<<i) != 0 {
			if val == 0 {
				val = d[i]
			} else if val != d[i] {
				return false
			}
		}
	}
	return true
}
func bitCount(mask int) int {
	n := 0
	for mask > 0 {
		n += mask & 1
		mask >>= 1
	}
	return n
}
func brute(d Dice) [15]int {
	var out [15]int
	for _, v := range d {
		out[v-1] += v
		out[6] += v
	}
	// Search every subset of five physical dice. Do not construct frequency tables.
	for mask := 1; mask < 32; mask++ {
		n := bitCount(mask)
		if n < 2 || !equalGroup(d, mask) {
			continue
		}
		face := 0
		for i := 0; i < 5; i++ {
			if mask&(1<<i) != 0 {
				face = d[i]
				break
			}
		}
		if n == 2 && 2*face > out[8] {
			out[8] = 2 * face
		}
		if n == 3 && 3*face > out[10] {
			out[10] = 3 * face
		}
		if n == 4 && 4*face > out[11] {
			out[11] = 4 * face
		}
		if n == 5 {
			out[7] = 50
		}
		if n == 2 {
			for other := mask + 1; other < 32; other++ {
				if bitCount(other) == 2 && other&mask == 0 && equalGroup(d, other) {
					v := 0
					for j := 0; j < 5; j++ {
						if other&(1<<j) != 0 {
							v = d[j]
							break
						}
					}
					if v != face && 2*(face+v) > out[9] {
						out[9] = 2 * (face + v)
					}
				}
			}
		}
		if n == 3 {
			other := 31 ^ mask
			if equalGroup(d, other) {
				v := 0
				for j := 0; j < 5; j++ {
					if other&(1<<j) != 0 {
						v = d[j]
						break
					}
				}
				if v != face {
					out[14] = 3*face + 2*v
				}
			}
		}
	}
	// Verify straights by sorting five independent dice values, not a histogram.
	vals := []int{d[0], d[1], d[2], d[3], d[4]}
	for i := 0; i < 5; i++ {
		for j := i + 1; j < 5; j++ {
			if vals[j] < vals[i] {
				vals[i], vals[j] = vals[j], vals[i]
			}
		}
	}
	if vals[0] == 1 && vals[1] == 2 && vals[2] == 3 && vals[3] == 4 && vals[4] == 5 {
		out[12] = 15
	}
	if vals[0] == 2 && vals[1] == 3 && vals[2] == 4 && vals[3] == 5 && vals[4] == 6 {
		out[13] = 20
	}
	return out
}
func run(executable string, rolls []Dice, bases []int, invalid []string) error {
	var input strings.Builder
	for _, d := range rolls {
		fmt.Fprintf(&input, "%d %d %d %d %d\n", d[0], d[1], d[2], d[3], d[4])
	}
	for _, s := range invalid {
		input.WriteString(s + "\n")
	}
	cmd := exec.Command(executable)
	cmd.Stdin = strings.NewReader(input.String())
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	raw, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("CLI failed: %w %s", err, stderr.String())
	}
	lines := strings.Split(strings.TrimSuffix(string(raw), "\n"), "\n")
	if len(lines) != len(rolls)+len(invalid) {
		return fmt.Errorf("output lines %d != %d", len(lines), len(rolls)+len(invalid))
	}
	for i, d := range rolls {
		fields := strings.Fields(lines[i])
		if len(fields) != 15 {
			return fmt.Errorf("roll %v: expected 15 scores, got %q", d, lines[i])
		}
		want := brute(d)
		for c, s := range fields {
			got, e := strconv.Atoi(s)
			if e != nil || got != want[c] {
				return fmt.Errorf("roll %v category %d got %q expected %d", d, c, s, want[c])
			}
		}
	}
	for i, base := range bases {
		if lines[7776+i] != lines[base] {
			return fmt.Errorf("metamorphic permutation %d changed scores", i)
		}
	}
	for i, s := range invalid {
		if lines[len(rolls)+i] != "ERR" {
			return fmt.Errorf("invalid %q accepted: %q", s, lines[len(rolls)+i])
		}
	}
	return nil
}
func main() {
	if len(os.Args) != 2 {
		panic("usage: go run oracle.go path-to-cpp-cli")
	}
	exe := os.Args[1]
	rolls := make([]Dice, 0, 8776)
	for a := 1; a <= 6; a++ {
		for b := 1; b <= 6; b++ {
			for c := 1; c <= 6; c++ {
				for d := 1; d <= 6; d++ {
					for e := 1; e <= 6; e++ {
						rolls = append(rolls, Dice{a, b, c, d, e})
					}
				}
			}
		}
	}
	rng := rand.New(rand.NewSource(31026))
	bases := make([]int, 0, 1000)
	for i := 0; i < 1000; i++ {
		base := rng.Intn(7776)
		bases = append(bases, base)
		d := rolls[base]
		rng.Shuffle(5, func(i, j int) { d[i], d[j] = d[j], d[i] })
		rolls = append(rolls, d)
	}
	invalid := []string{"0 1 2 3 4", "1 2 3 4 7", "1 2 3 4", "1 2 3 4 5 6", "1 2 3 4 x", "1 2 3 4 5.0", "", "-1 1 1 1 1"}
	if err := run(exe, rolls, bases, invalid); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("GO independent physical-dice subset oracle: %d valid rolls x 15 scores = %d differential assertions; 1000 metamorphic permutation pairs; %d malformed lines rejected PASS\n", len(rolls), len(rolls)*15, len(invalid))
}
