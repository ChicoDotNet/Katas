# KATA-000057 — Parallel Letter Frequency (Go 1.23)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/parallel-letter-frequency, root MIT license: https://github.com/exercism/problem-specifications/blob/main/LICENSE. Original Go code, tests and Python oracle MIT; no upstream starter or canonical cases copied.

**Locally specified contract:** aggregate frequencies of Unicode letters across a list of texts using 1–32 worker goroutines; ignore nonletters; lowercase each letter using Go's rune-level unicode.ToLower (simple mapping, not full Unicode casefold). Each worker owns its private map. Results are merged serially after workers complete, ensuring deterministic counts. No reliance on nondeterministic map iteration for serialization. Reject invalid worker counts. The workload is finite and bounded by caller-provided texts; no guarantee of speedup for tiny inputs.

**Language:** Go channels and goroutines make worker-level ownership explicit. The independent Python oracle uses a sequential Counter and a test alphabet with single-codepoint lowercase, avoiding known Unicode full-fold differences. Race detector validates observed executions; it does not formally prove absence of every possible race.

Run:

~~~sh
cd katas/KATA-000057
go test -race ./...
go build -o /tmp/frequency-cli ./cmd/frequency
python3 tests/differential.py /tmp/frequency-cli
if KATA_RED=1 go test ./... >/tmp/frequency-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/frequency-red.log
~~~

Local Go/Python: deterministic tests, race detector green, 907 independent workloads and behaviorally failing RED. Provisional difficulty 5/5, score 91/100 (uncalibrated). Evidence in evidence/ and Ninja OBS-028.
