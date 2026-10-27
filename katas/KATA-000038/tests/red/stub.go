package red

import "net/http"

func New() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { http.Error(w, "not implemented", 501) })
}
