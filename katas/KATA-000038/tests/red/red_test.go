package red

import (
	"net/http/httptest"
	"testing"
)

func TestREDBehavior(t *testing.T) {
	w := httptest.NewRecorder()
	New().ServeHTTP(w, httptest.NewRequest("GET", "/users", nil))
	if w.Code != 200 {
		t.Fatalf("behavioral RED: GET /users returned %d; expected 200", w.Code)
	}
}
