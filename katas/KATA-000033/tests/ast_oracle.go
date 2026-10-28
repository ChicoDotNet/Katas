// SPDX-License-Identifier: MIT
// Construct an expression AST before emitting Forth. Expected values are computed
// by recursive tree evaluation, never by interpreting or replaying Forth tokens.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

type expr struct {
	op          byte
	value       int64
	left, right *expr
}
type sample struct {
	Program string
	Want    []int64
	Err     string
	Kind    string
}
type answer struct {
	Stack []int64 `json:"stack"`
	Error string  `json:"error"`
}

func eval(e *expr) int64 {
	if e.op == 0 {
		return e.value
	}
	a, b := eval(e.left), eval(e.right)
	switch e.op {
	case '+':
		return a + b
	case '-':
		return a - b
	case '*':
		return a * b
	case '/':
		return a / b // Go integer division truncates toward zero.
	}
	panic("unreachable")
}
func emit(e *expr) string {
	if e.op == 0 {
		return strconv.FormatInt(e.value, 10)
	}
	return emit(e.left) + " " + emit(e.right) + " " + string(e.op)
}
func generate(r *rand.Rand, depth int) *expr {
	if depth == 0 || r.Intn(5) == 0 {
		return &expr{value: int64(r.Intn(19) - 9)}
	}
	op := []byte{'+', '-', '*', '/'}[r.Intn(4)]
	left := generate(r, depth-1)
	right := generate(r, depth-1)
	if op == '/' && eval(right) == 0 {
		right = &expr{value: int64(r.Intn(9) + 1)}
	}
	e := &expr{op: op, left: left, right: right}
	// Restrict the generator's numeric domain; large integer boundaries are
	// exercised independently by fixed error witnesses below.
	if v := eval(e); v > 1000000 || v < -1000000 {
		return &expr{value: int64(r.Intn(19) - 9)}
	}
	return e
}
func cases() []sample {
	r := rand.New(rand.NewSource(20261028))
	samples := []sample{
		{Program: "-7 3 /", Want: []int64{-2}, Kind: "negative-division"},
		{Program: "7 -3 /", Want: []int64{-2}, Kind: "negative-division"},
		{Program: "-7 -3 /", Want: []int64{2}, Kind: "negative-division"},
		{Program: ": COPY dup ; : DUP 8 ; 3 COPY DUP", Want: []int64{3, 3, 8}, Kind: "primitive-freeze"},
		{Program: ": x 3 ; : x x 1 + ; x", Want: []int64{4}, Kind: "self-redefinition"},
		{Program: ": x 5 ; : y x ; : x 9 ; y x", Want: []int64{5, 9}, Kind: "definition-freeze"},
		{Program: "1 2 SWAP OVER DROP", Want: []int64{2, 1}, Kind: "stack-primitive"},
		{Program: "1 +", Err: "underflow", Kind: "underflow"},
		{Program: "1 swap", Err: "underflow", Kind: "underflow"},
		{Program: "4 0 /", Err: "zero", Kind: "division-zero"},
		{Program: ": 3 1 ;", Err: "invalid", Kind: "invalid-name"},
		{Program: ": a 2", Err: "invalid", Kind: "missing-semicolon"},
		{Program: ": a 2 : b 3 ;", Err: "invalid", Kind: "nested-definition"},
		{Program: ";", Err: "invalid", Kind: "unexpected-semicolon"},
		{Program: ": a missing ;", Err: "unknown", Kind: "unknown-in-definition"},
		{Program: "9007199254740992", Err: "invalid", Kind: "unsafe-literal"},
		{Program: "9007199254740991 2 *", Err: "overflow", Kind: "overflow"},
	}
	for i := 0; i < 300; i++ {
		a, b := generate(r, 4), generate(r, 4)
		p, q := emit(a), emit(b)
		x, y := eval(a), eval(b)
		// Five structural witnesses per AST pair. A reference VM would simply
		// duplicate the implementation's token and definition-resolution rules;
		// these expectations instead come from the expression tree and the
		// independently specified frozen-binding metamorphic relation.
		samples = append(samples,
			sample{Program: p, Want: []int64{x}, Kind: "ast-direct"},
			sample{Program: p + " \n\t " + q, Want: []int64{x, y}, Kind: "ast-composition"},
			sample{Program: ": foo " + p + " ; FOO", Want: []int64{x}, Kind: "ast-definition"},
			sample{Program: ": foo " + p + " ; : alias foo ; : foo " + q + " ; ALIAS fOo", Want: []int64{x, y}, Kind: "frozen-alias"},
			sample{Program: ": foo " + p + " ; : foo foo 1 + ; foo", Want: []int64{x + 1}, Kind: "self-redefinition"},
			sample{Program: ": dup " + p + " ; 2 DUP", Want: []int64{2, x}, Kind: "builtin-shadow"},
			sample{Program: ": copy dup ; : dup " + p + " ; 7 COPY dup", Want: []int64{7, 7, x}, Kind: "builtin-freeze"},
		)
	}
	return samples
}
func main() {
	ss := cases()
	programs := make([]string, len(ss))
	for i, s := range ss {
		programs[i] = s.Program
	}
	data, err := json.Marshal(programs)
	if err != nil {
		panic(err)
	}
	cli := "cli.js"
	if v := os.Getenv("FORTH_CLI"); v != "" {
		cli = v
	}
	cmd := exec.Command("node", cli)
	cmd.Stdin = bytes.NewReader(data)
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "node execution failed: %v: %s\n", err, output)
		os.Exit(2)
	}
	var got []answer
	if err := json.Unmarshal(output, &got); err != nil {
		fmt.Fprintf(os.Stderr, "invalid JSON: %v %s\n", err, output)
		os.Exit(2)
	}
	if len(got) != len(ss) {
		fmt.Fprintf(os.Stderr, "count mismatch: %d != %d\n", len(got), len(ss))
		os.Exit(1)
	}
	counts := map[string]int{}
	for i, s := range ss {
		counts[s.Kind]++
		if s.Err != "" {
			if got[i].Error != s.Err {
				fmt.Fprintf(os.Stderr, "FAIL case %d (%s): expected error %s, got %+v: %s\n", i, s.Kind, s.Err, got[i], s.Program)
				os.Exit(1)
			}
			continue
		}
		if got[i].Error != "" || len(got[i].Stack) != len(s.Want) {
			fmt.Fprintf(os.Stderr, "FAIL case %d (%s): want %v, got %+v: %s\n", i, s.Kind, s.Want, got[i], s.Program)
			os.Exit(1)
		}
		for j, v := range s.Want {
			if got[i].Stack[j] != v {
				fmt.Fprintf(os.Stderr, "FAIL case %d (%s) stack[%d]: want %d got %d: %s\n", i, s.Kind, j, v, got[i].Stack[j], s.Program)
				os.Exit(1)
			}
		}
	}
	fmt.Printf("PASS: %d AST-first, frozen-binding, metamorphic and invalid-input witnesses (%d classes)\n", len(ss), len(counts))
	fmt.Printf("Classes: ")
	names := []string{"ast-direct", "ast-composition", "ast-definition", "frozen-alias", "self-redefinition", "builtin-shadow", "builtin-freeze", "negative-division"}
	parts := make([]string, 0, len(names))
	for _, n := range names {
		parts = append(parts, fmt.Sprintf("%s=%d", n, counts[n]))
	}
	fmt.Println(strings.Join(parts, ", "))
}
