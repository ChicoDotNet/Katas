package main

import (
	"bytes"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"sort"
	"strconv"
	"strings"
)

type plan struct {
	c     [4]int
	price int
}

var widths = [4]int{50, 75, 100, 120}
var prices = [4]int{59, 62, 90, 111}

// Independent count-vector enumeration. No memoization, recursive decomposition,
// or translation of the Swift dynamic-programming suffix construction.
func brute(wall int) []plan {
	var found []plan
	for a := 0; a <= wall/widths[0]; a++ {
		for b := 0; b <= wall/widths[1]; b++ {
			for c := 0; c <= wall/widths[2]; c++ {
				rem := wall - a*widths[0] - b*widths[1] - c*widths[2]
				if rem < 0 || rem%widths[3] != 0 {
					continue
				}
				d := rem / widths[3]
				counts := [4]int{a, b, c, d}
				cost := 0
				for i, x := range counts {
					cost += x * prices[i]
				}
				found = append(found, plan{counts, cost})
			}
		}
	}
	sort.Slice(found, func(i, j int) bool {
		for k := 0; k < 4; k++ {
			if found[i].c[k] != found[j].c[k] {
				return found[i].c[k] < found[j].c[k]
			}
		}
		return false
	})
	return found
}
func key(c [4]int) string { return fmt.Sprintf("%d,%d,%d,%d", c[0], c[1], c[2], c[3]) }

// Compare count vectors numerically, not as decimal strings: "10" < "2" is
// a lexical artifact and is wrong for count-vector tie breaking.
func lessCounts(a, b [4]int) bool {
	for i := 0; i < 4; i++ {
		if a[i] != b[i] {
			return a[i] < b[i]
		}
	}
	return false
}
func expected(plans []plan) string {
	var b strings.Builder
	fmt.Fprintf(&b, "COUNT %d\n", len(plans))
	var cheapest *plan
	for _, p := range plans {
		fmt.Fprintf(&b, "PLAN %s PRICE %d\n", key(p.c), p.price)
		if cheapest == nil || p.price < cheapest.price || (p.price == cheapest.price && lessCounts(p.c, cheapest.c)) {
			v := p
			cheapest = &v
		}
	}
	if cheapest == nil {
		b.WriteString("CHEAPEST NONE\n")
	} else {
		fmt.Fprintf(&b, "CHEAPEST %s PRICE %d\n", key(cheapest.c), cheapest.price)
	}
	return b.String()
}
func run(binary string, args ...string) (string, error) {
	cmd := exec.Command(binary, args...)
	out, err := cmd.CombinedOutput()
	return string(out), err
}
func main() {
	if len(os.Args) != 2 {
		panic("expected compiled Swift executable path")
	}
	binary := os.Args[1]
	// Independent comparator regression: synthetic equal-price candidates
	// exercise two-digit quantities even when real fixed prices have no ties.
	if !lessCounts([4]int{2, 0, 0, 0}, [4]int{10, 0, 0, 0}) || lessCounts([4]int{10, 0, 0, 0}, [4]int{2, 0, 0, 0}) {
		panic("numeric count-vector comparator regression")
	}
	count := 0
	cache := make(map[int][]plan)
	for wall := 0; wall <= 1000; wall++ {
		ps := brute(wall)
		cache[wall] = ps
		actual, err := run(binary, strconv.Itoa(wall))
		if err != nil || actual != expected(ps) {
			panic(fmt.Sprintf("wall=%d error=%v\nEXPECTED:\n%s\nACTUAL:\n%s", wall, err, expected(ps), actual))
		}
		count++
	}
	// Metamorphic injection: adding one 50cm module maps every valid plan for
	// w into a valid plan for w+50, and cannot increase optimal price by >59.
	metamorphic := 0
	for wall := 0; wall <= 950; wall++ {
		plus := make(map[[4]int]bool)
		for _, p := range cache[wall+50] {
			plus[p.c] = true
		}
		for _, p := range cache[wall] {
			next := p.c
			next[0]++
			if !plus[next] {
				panic(fmt.Sprintf("50cm injection lost at wall %d", wall))
			}
			metamorphic++
		}
		if len(cache[wall]) > 0 {
			cheap := func(p []plan) int {
				v := p[0].price
				for _, x := range p {
					if x.price < v {
						v = x.price
					}
				}
				return v
			}
			if cheap(cache[wall+50]) > cheap(cache[wall])+59 {
				panic("price upper-bound metamorphism")
			}
		}
	}
	rng := rand.New(rand.NewSource(20261030))
	padded := 0
	for i := 0; i < 120; i++ {
		wall := rng.Intn(1001)
		paddedArg := fmt.Sprintf("%04d", wall)
		actual, err := run(binary, paddedArg)
		if err != nil || actual != expected(cache[wall]) {
			panic(fmt.Sprintf("leading-zero metamorphism %q: %v", paddedArg, err))
		}
		padded++
	}
	bad := []string{"", "-1", "+1", "1.0", " 50", "50 ", "50\n", "1_00", "1001", "999999999999999999999999999", "１２", "١٠٠", "NaN"}
	for _, s := range bad {
		out, err := run(binary, s)
		if err == nil || !bytes.HasPrefix([]byte(out), []byte("ERR:wall")) {
			panic(fmt.Sprintf("invalid arg %q accepted or wrong error: %q %v", s, out, err))
		}
	}
	for _, args := range [][]string{{}, {"50", "100"}} {
		out, err := run(binary, args...)
		if err == nil || !strings.HasPrefix(out, "ERR:wall") {
			panic(fmt.Sprintf("arity %v accepted: %q %v", args, out, err))
		}
	}
	fmt.Printf("GO independent brute oracle: %d wall values, %d 50cm injection metamorphisms, %d padded-input metamorphisms, %d invalid CLI rejections PASS\n", count, metamorphic, padded, len(bad)+2)
}
