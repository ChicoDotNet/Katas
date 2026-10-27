package restapi

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http/httptest"
	"reflect"
	"sync"
	"testing"
)

func request(t *testing.T, a *API, method, path, body string) (int, map[string]any) {
	t.Helper()
	r := httptest.NewRequest(method, path, bytes.NewBufferString(body))
	w := httptest.NewRecorder()
	a.ServeHTTP(w, r)
	var obj map[string]any
	if e := json.Unmarshal(w.Body.Bytes(), &obj); e != nil {
		t.Fatal(e)
	}
	return w.Code, obj
}
func users(t *testing.T, a *API) []any {
	t.Helper()
	status, body := request(t, a, "GET", "/users", "")
	if status != 200 {
		t.Fatal(status)
	}
	return body["users"].([]any)
}
func TestSettlementAndBalances(t *testing.T) {
	a, _ := New([]string{"Zoe", "Ada", "Bob"})
	for _, v := range []struct {
		l, b string
		n    string
	}{{"Ada", "Bob", "12.25"}, {"Bob", "Ada", "7.00"}, {"Zoe", "Ada", "2.25"}, {"Ada", "Zoe", "2.25"}} {
		status, _ := request(t, a, "POST", "/iou", fmt.Sprintf(`{"lender":%q,"borrower":%q,"amount":%s}`, v.l, v.b, v.n))
		if status != 200 {
			t.Fatal(status)
		}
	}
	got := users(t, a)
	if len(got) != 3 {
		t.Fatal(got)
	}
	ada := got[0].(map[string]any)
	bob := got[1].(map[string]any)
	zoe := got[2].(map[string]any)
	if ada["name"] != "Ada" || ada["balance"] != 5.25 || bob["balance"] != -5.25 || zoe["balance"] != 0.0 {
		t.Fatalf("balances %v", got)
	}
	if !reflect.DeepEqual(ada["owed_by"], map[string]any{"Bob": 5.25}) || len(zoe["owes"].(map[string]any)) != 0 {
		t.Fatal(got)
	}
	status, filtered := request(t, a, "GET", "/users", `{"users":["Zoe","Ada"]}`)
	if status != 200 || len(filtered["users"].([]any)) != 2 {
		t.Fatal(filtered)
	}
}
func TestAtomicErrors(t *testing.T) {
	a, _ := New([]string{"Ada", "Bob"})
	cases := []struct {
		method, path, body string
		code               int
	}{
		{"POST", "/iou", `{"lender":"Ada","borrower":"Ada","amount":1}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Nobody","amount":1}`, 404},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":-1}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":0}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":1.001}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":1e2}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":1000000001}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":"3"}`, 400},
		{"POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":1} {}`, 400},
		{"POST", "/add", `{"user":"Ada"}`, 409},
		{"POST", "/add", `{"user":"  X"}`, 400},
		{"GET", "/users", `{"users":["Ghost"]}`, 404},
		{"PATCH", "/users", "", 404},
	}
	before := users(t, a)
	for _, c := range cases {
		code, _ := request(t, a, c.method, c.path, c.body)
		if code != c.code {
			t.Errorf("%s %s %s: got %d want %d", c.method, c.path, c.body, code, c.code)
		}
	}
	if !reflect.DeepEqual(before, users(t, a)) {
		t.Fatal("invalid requests mutated state")
	}
	status, _ := request(t, a, "POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":1000000000}`)
	if status != 200 {
		t.Fatal(status)
	}
	before = users(t, a)
	status, _ = request(t, a, "POST", "/iou", `{"lender":"Ada","borrower":"Bob","amount":0.01}`)
	if status != 400 || !reflect.DeepEqual(before, users(t, a)) {
		t.Fatal("overflow not atomic")
	}
}
func TestConservationConcurrent(t *testing.T) {
	a, _ := New([]string{"Ada", "Bob", "Cal", "Dee"})
	var wg sync.WaitGroup
	for j := 0; j < 8; j++ {
		wg.Add(1)
		go func(j int) {
			defer wg.Done()
			for i := 0; i < 100; i++ {
				l, b := "Ada", "Bob"
				if j%2 == 1 {
					l, b = b, l
				}
				req := httptest.NewRequest("POST", "/iou", bytes.NewBufferString(fmt.Sprintf(`{"lender":%q,"borrower":%q,"amount":0.01}`, l, b)))
				w := httptest.NewRecorder()
				a.ServeHTTP(w, req)
				if w.Code != 200 {
					t.Errorf("concurrent status %d", w.Code)
				}
			}
		}(j)
	}
	wg.Wait()
	all := users(t, a)
	sum := 0.0
	for _, v := range all {
		u := v.(map[string]any)
		sum += u["balance"].(float64)
	}
	if sum != 0 {
		t.Fatal("nonzero global balance", sum)
	}
	if all[0].(map[string]any)["balance"].(float64) != 0 {
		t.Fatalf("opposite loans did not cancel: %+v net=%+v", all, a.net)
	}
}
func TestNew(t *testing.T) {
	for _, v := range [][]string{{"Ada", "Ada"}, {""}, {" X"}} {
		if _, e := New(v); e == nil {
			t.Fatal("accepted invalid", v)
		}
	}
}
