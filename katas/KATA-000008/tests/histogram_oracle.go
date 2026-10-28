// SPDX-License-Identifier: MIT
// Independent position-frequency (histogram/dot-product) model and metamorphic
// checks for the original Swift Race Car Leaderboard. No upstream fixtures.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"reflect"
	"sort"
)

type Scenario struct {
	Races [][]*string `json:"races"`
}
type Standing struct {
	Driver string `json:"driver"`
	Points int    `json:"points"`
}

var weights = [10]int{25, 18, 15, 12, 10, 8, 6, 4, 2, 1}

func ptr(s string) *string { return &s }
func clone(s Scenario) Scenario {
	out := Scenario{Races: make([][]*string, len(s.Races))}
	for i, r := range s.Races {
		out.Races[i] = append([]*string(nil), r...)
	}
	return out
}

// Unlike the production Swift per-race running totals, the reference first
// builds a driver-by-finish-position incidence matrix, then applies a dot product.
func histogram(s Scenario) []Standing {
	counts := map[string]*[10]int{}
	for _, race := range s.Races {
		for place, name := range race {
			if name == nil {
				continue
			}
			row := counts[*name]
			if row == nil {
				row = &[10]int{}
				counts[*name] = row
			}
			row[place]++
		}
	}
	out := make([]Standing, 0, len(counts))
	for driver, row := range counts {
		total := 0
		for i, n := range row {
			total += n * weights[i]
		}
		out = append(out, Standing{driver, total})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Points == out[j].Points {
			return out[i].Driver < out[j].Driver
		}
		return out[i].Points > out[j].Points
	})
	return out
}
func totals(x []Standing) map[string]int {
	m := map[string]int{}
	for _, v := range x {
		m[v.Driver] = v.Points
	}
	return m
}
func randomSeason(rng *rand.Rand) Scenario {
	n := rng.Intn(25)
	s := Scenario{Races: make([][]*string, 0, n)}
	for j := 0; j < n; j++ {
		size := 1 + rng.Intn(10)
		ids := rng.Perm(16)
		race := make([]*string, size)
		for i := range race {
			if rng.Intn(4) != 0 {
				race[i] = ptr(fmt.Sprintf("D%02d", ids[i]))
			}
		}
		s.Races = append(s.Races, race)
	}
	return s
}
func reverseRaces(s Scenario) Scenario {
	x := clone(s)
	for i, j := 0, len(x.Races)-1; i < j; i, j = i+1, j-1 {
		x.Races[i], x.Races[j] = x.Races[j], x.Races[i]
	}
	return x
}
func nilOnly(s Scenario) Scenario {
	x := clone(s)
	x.Races = append(x.Races, []*string{nil, nil, nil})
	return x
}
func trailingNil(s Scenario) Scenario {
	x := clone(s)
	for i, r := range x.Races {
		if len(r) < 10 {
			x.Races[i] = append(r, nil)
		}
	}
	return x
}
func renamed(s Scenario) Scenario {
	x := clone(s)
	for _, r := range x.Races {
		for i, name := range r {
			if name != nil {
				r[i] = ptr("Z" + *name)
			}
		}
	}
	return x
}
func prefixNil(s Scenario) Scenario {
	x := clone(s)
	for i, r := range x.Races {
		if len(r) < 10 {
			x.Races[i] = append([]*string{nil}, r...)
		}
	}
	return x
}
func reversePlaces(s Scenario) Scenario {
	x := clone(s)
	for _, r := range x.Races {
		for i, j := 0, len(r)-1; i < j; i, j = i+1, j-1 {
			r[i], r[j] = r[j], r[i]
		}
	}
	return x
}
func runCLI(cli string, scenarios []Scenario) ([][]Standing, error) {
	input, err := json.Marshal(scenarios)
	if err != nil {
		return nil, err
	}
	cmd := exec.Command(cli)
	cmd.Stdin = bytes.NewReader(input)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("Swift CLI: %w: %s", err, output)
	}
	var result [][]Standing
	if err = json.Unmarshal(output, &result); err != nil {
		return nil, fmt.Errorf("decode Swift: %w: %s", err, output)
	}
	return result, nil
}
func assert(ok bool, format string, args ...any) {
	if !ok {
		fmt.Fprintf(os.Stderr, "FAIL histogram/metamorphic: "+format+"\n", args...)
		os.Exit(1)
	}
}
func main() {
	assert(len(os.Args) == 2, "usage: histogram_oracle <swift-cli>")
	rng := rand.New(rand.NewSource(20261028))
	const n = 220
	const variants = 7
	cases := make([]Scenario, 0, n*variants+2)
	for i := 0; i < n; i++ {
		s := randomSeason(rng)
		cases = append(cases, s, reverseRaces(s), nilOnly(s), trailingNil(s), renamed(s), prefixNil(s), reversePlaces(s))
		// Additivity is a separate algebraic property, not a second copy of the Swift loop.
		mid := len(s.Races) / 2
		left := histogram(Scenario{Races: s.Races[:mid]})
		right := histogram(Scenario{Races: s.Races[mid:]})
		combined := totals(left)
		for driver, points := range totals(right) {
			combined[driver] += points
		}
		assert(reflect.DeepEqual(combined, totals(histogram(s))), "histogram partition additivity case %d", i)
	}
	cases = append(cases, Scenario{Races: [][]*string{{nil, ptr("Ada")}}}, Scenario{Races: [][]*string{{ptr("Ada"), ptr("Bea")}, {ptr("Bea"), ptr("Ada")}}})
	found, err := runCLI(os.Args[1], cases)
	assert(err == nil, "%v", err)
	assert(len(found) == len(cases), "response length %d != %d", len(found), len(cases))
	for i, s := range cases {
		want := histogram(s)
		assert(reflect.DeepEqual(found[i], want), "case %d: got=%v want=%v", i, found[i], want)
	}
	invariants := 0
	for i := 0; i < n; i++ {
		base := found[i*variants]
		for _, offset := range []int{1, 2, 3} {
			assert(reflect.DeepEqual(base, found[i*variants+offset]), "invariance case %d variant %d", i, offset)
			invariants++
		}
		renamedExpected := make([]Standing, len(base))
		for j, v := range base {
			renamedExpected[j] = Standing{"Z" + v.Driver, v.Points}
		}
		assert(reflect.DeepEqual(renamedExpected, found[i*variants+4]), "rename equivariance case %d", i)
		invariants++
	}
	assert(len(found[len(found)-2]) == 1 && found[len(found)-2][0].Points == 18, "nil must consume finishing position")
	assert(len(found[len(found)-1]) == 2 && found[len(found)-1][0].Driver == "Ada" && found[len(found)-1][1].Driver == "Bea", "alphabetic tie")
	fmt.Printf("PASS histogram oracle: %d Swift comparisons, %d metamorphic invariants, %d partition-additivity witnesses, nil/tie witnesses\n", len(cases), invariants, n)
}
