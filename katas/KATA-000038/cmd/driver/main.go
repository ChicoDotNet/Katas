package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"kata038/src"
	"net/http/httptest"
	"os"
	"strings"
)

type Command struct {
	Reset  *[]string       `json:"reset,omitempty"`
	Method string          `json:"method"`
	Path   string          `json:"path"`
	Body   json.RawMessage `json:"body"`
}

func main() {
	scan := bufio.NewScanner(os.Stdin)
	scan.Buffer(make([]byte, 4096), 1024*1024)
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	var api *restapi.API
	for scan.Scan() {
		var cmd Command
		if err := json.Unmarshal(scan.Bytes(), &cmd); err != nil {
			fmt.Fprintln(out, `{"status":400,"body":{"error":"Bad Request"}}`)
			out.Flush()
			continue
		}
		if cmd.Reset != nil {
			var err error
			api, err = restapi.New(*cmd.Reset)
			if err != nil {
				fmt.Fprintln(out, `{"status":400,"body":{"error":"Bad Request"}}`)
			} else {
				fmt.Fprintln(out, `{"status":200,"body":{"reset":true}}`)
			}
			out.Flush()
			continue
		}
		if api == nil {
			fmt.Fprintln(out, `{"status":400,"body":{"error":"Bad Request"}}`)
			out.Flush()
			continue
		}
		if !strings.HasPrefix(cmd.Path, "/") || cmd.Method == "" {
			fmt.Fprintln(out, `{"status":400,"body":{"error":"Bad Request"}}`)
			out.Flush()
			continue
		}
		body := cmd.Body
		if body == nil {
			body = []byte("")
		}
		req := httptest.NewRequest(cmd.Method, cmd.Path, bytes.NewReader(body))
		w := httptest.NewRecorder()
		api.ServeHTTP(w, req)
		var value any
		if err := json.Unmarshal(w.Body.Bytes(), &value); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		result, _ := json.Marshal(map[string]any{"status": w.Code, "body": value})
		fmt.Fprintln(out, string(result))
		out.Flush()
	}
	if err := scan.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
