# KATA-000028 — The Lift (Go 1.23)

Source: https://kata-log.rocks/lift-kata (Kata-Log's own public-domain exercise). No upstream starter, source or tests copied. Original Go and Python code MIT-licensed.

The original exercise suggests multiple possible capabilities rather than a fully fixed acceptance specification. Our explicitly **chosen contract**: single elevator, floors numbered 0..Max, queue of source/destination calls dispatched FIFO. The lift never moves until Tick is invoked. One Tick moves at most one floor toward the current target; when it reaches the target, a pickup or dropoff event is emitted on that same Tick. If already at the source floor, pickup consumes its own Tick; an equal source/destination needs a second Tick to drop off. After a delivery, the next queued job begins on a later Tick. Empty queue produces an idle event, with no floor movement. Input validation rejects floors outside the building before enqueuing a request.

Go has value records, explicit queue mutation and low-ceremony deterministic Tick behavior. Erlang actors might be appropriate for real distributed lift controllers, but this kata models one synchronous elevator, not fault-tolerant concurrency. Python independently computes trips and complete event traces.

Reproduce:
~~~sh
cd katas/KATA-000028
go test ./...
go build -o /tmp/ninja-lift ./cmd/lift
python3 tests/differential.py /tmp/ninja-lift
if go test -tags kata_red ./... >/tmp/ninja-lift-red.log 2>&1; then exit 1; fi
grep -q 'unexpected trace' /tmp/ninja-lift-red.log
~~~

Local Go 1.23.2: tests cover travel, FIFO, source=destination, idle state, and invalid floors; 300 cross-language differential traces passed; behavioral RED emitted the expected trace mismatch. O(total distance travelled + calls) tick operations, O(pending calls) state. Author-only provisional score 89/100, difficulty 5/5.

Limitations: no multiple shafts, passenger capacity, call priority, dynamic reordering, door delays, maintenance or safety certification. This is not production elevator control software.

Evidence: evidence/red.txt, green.txt, oracle.txt, ci.txt, skill_review.md.
