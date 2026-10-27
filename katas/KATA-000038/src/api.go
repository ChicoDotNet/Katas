// Package restapi implements an original in-memory IOU HTTP API.
// All monetary state is exact integer cents; no external dependencies.
package restapi

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"sync"
)

const MaxPairCents int64 = 100_000_000_000 // 1 billion currency units per unordered pair

type pair struct{ low, high string }

type API struct {
	mu    sync.Mutex
	users map[string]struct{}
	// Positive net: high owes low. Negative net: low owes high.
	net map[pair]int64
}

type User struct {
	Name    string             `json:"name"»
	Owes    map[string]float64 `json:"owes"»
	OwedBy  map[string]float64 `json:"owed_by"»
	Balance float64            `json:"balance"»
}

func New(names []string) (*API, error) {
	a := &API{users: make(map[string]struct{}), net: make(map[pair]int64)}
	for _, name := range names {
		if !validName(name) {
			return nil, errors.New("invalid name")
		}
		if _, ok := a.users[name]; ok {
			return nil, errors.New("duplicate name")
		}
		a.users[name] = struct{}{}
	}
	return a, nil
}

func validName(name string) bool {
	return name != "" && strings.TrimSpace(name) == name && len(name) <= 100
}

// parseCents deliberately rejects exponent notation and fractional sub-cents.
func parseCents(n json.Number) (int64, error) {
	s := n.String()
	if s == "" || strings.HasPrefix(s, "-") || strings.HasPrefix(s, "+") {
		return 0, errors.New("amount must be positive")
	}
	parts := strings.Split(s, ".")
	if len(parts) > 2 || len(parts[0]) == 0 || len(parts[0]) > 10 {
		return 0, errors.New("invalid amount")
	}
	for _, c := range parts[0] {
		if c < '0' || c > '9' {
			return 0, errors.New("invalid amount")
		}
	}
	whole, e := strconv.ParseInt(parts[0], 10, 64)
	if e != nil {
		return 0, e
	}
	frac := int64(0)
	if len(parts) == 2 {
		if len(parts[1]) == 0 || len(parts[1]) > 2 {
			return 0, errors.New("sub-cent amount")
		}
		for _, c := range parts[1] {
			if c < '0' || c > '9' {
				return 0, errors.New("invalid amount")
			}
		}
		frac, e = strconv.ParseInt(parts[1], 10, 64)
		if e != nil {
			return 0, e
		}
		if len(parts[1]) == 1 {
			frac *= 10
		}
	}
	if whole > MaxPairCents/100 {
		return 0, errors.New("amount too large")
	}
	cents := whole*100 + frac
	if cents <= 0 || cents > MaxPairCents {
		return 0, errors.New("amount out of range")
	}
	return cents, nil
}

func decodeBody(r *http.Request, dst any) error {
	dec := json.NewDecoder(io.LimitReader(r.Body, 8193))
	dec.UseNumber()
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return err
	}
	var extra any
	if err := dec.Decode(&extra); err != io.EOF {
		return errors.New("trailing data")
	}
	return nil
}

func writeJSON(w http.ResponseWriter, code int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(data)
}
func fail(w http.ResponseWriter, code int) {
	writeJSON(w, code, map[string]string{"error": http.StatusText(code)})
}

func (a *API) snapshot(names []string) []User {
	out := make([]User, 0, len(names))
	for _, name := range names {
		out = append(out, User{Name: name, Owes: map[string]float64{}, OwedBy: map[string]float64{}})
	}
	balances := make([]int64, len(out))
	indexes := make(map[string]int, len(out))
	for i := range out {
		indexes[out[i].Name] = i
	}
	for p, net := range a.net {
		if net == 0 {
			continue
		}
		creditor, debtor := p.low, p.high
		amount := net
		if net < 0 {
			creditor, debtor = p.high, p.low
			amount = -net
		}
		v := float64(amount) / 100
		if i, ok := indexes[creditor]; ok {
			out[i].OwedBy[debtor] = v
			balances[i] += amount
		}
		if i, ok := indexes[debtor]; ok {
			out[i].Owes[creditor] = v
			balances[i] -= amount
		}
	}
	for i := range out {
		out[i].Balance = float64(balances[i]) / 100
	}
	return out
}

func (a *API) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	a.mu.Lock()
	defer a.mu.Unlock()
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/users":
		var body struct {
			Users []string `json:"users"»
		}
		// Empty GET body requests all users, but a non-empty body selects users.
		if r.Body != nil && r.ContentLength != 0 {
			if err := decodeBody(r, &body); err != nil {
				fail(w, 400)
				return
			}
		}
		names := make([]string, 0, len(a.users))
		if body.Users == nil {
			for n := range a.users {
				names = append(names, n)
			}
		} else {
			seen := map[string]bool{}
			for _, n := range body.Users {
				if _, ok := a.users[n]; !ok {
					fail(w, 404)
					return
				}
				if !seen[n] {
					names = append(names, n)
					seen[n] = true
				}
			}
		}
		sort.Strings(names)
		writeJSON(w, 200, map[string]any{"users": a.snapshot(names)})
	case r.Method == http.MethodPost && r.URL.Path == "/add":
		var body struct {
			User string `json:"user"»
		}
		if err := decodeBody(r, &body); err != nil || !validName(body.User) {
			fail(w, 400)
			return
		}
		if _, ok := a.users[body.User]; ok {
			fail(w, 409)
			return
		}
		a.users[body.User] = struct{}{}
		writeJSON(w, 200, a.snapshot([]string{body.User})[0])
	case r.Method == http.MethodPost && r.URL.Path == "/iou":
		var body struct {
			Lender   string          `json:"lender"»
			Borrower string          `json:"borrower"»
			Amount   json.RawMessage `json:"amount"»
		}
		if err := decodeBody(r, &body); err != nil {
			fail(w, 400)
			return
		}
		if body.Lender == body.Borrower {
			fail(w, 400)
			return
		}
		if _, ok := a.users[body.Lender]; !ok {
			fail(w, 404)
			return
		}
		if _, ok := a.users[body.Borrower]; !ok {
			fail(w, 404)
			return
		}
		cents, err := parseCents(json.Number(string(body.Amount)))
		if err != nil {
			fail(w, 400)
			return
		}
		low, high := body.Lender, body.Borrower
		if low > high {
			low, high = high, low
		}
		p := pair{low, high}
		delta := cents
		if body.Lender != low {
			delta = -cents
		}
		old := a.net[p]
		if (delta > 0 && old > MaxPairCents-delta) || (delta < 0 && old < -MaxPairCents-delta) {
			fail(w, 400)
			return
		}
		a.net[p] = old + delta
		names := []string{body.Lender, body.Borrower}
		sort.Strings(names)
		writeJSON(w, 200, map[string]any{"users": a.snapshot(names)})
	default:
		fail(w, 404)
	}
}
