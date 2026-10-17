# KATA-000044 — Dominoes in Go

Source: [Exercism Dominoes](https://github.com/exercism/problem-specifications/tree/main/exercises/dominoes), MIT [repository license](https://github.com/exercism/problem-specifications/blob/main/LICENSE). **No upstream statement, starter code or canonical test data copied.** Implementation, tests, and oracle are original MIT.

Each tile is an undirected **physical edge** of a multigraph. Solve decides whether every tile can form a continuous, closed chain and returns a valid chain. Tiles may be reversed; empty input permits an empty chain. Even degrees are necessary but not sufficient: all vertices of positive degree must also be connected. Self-loops and parallel tiles retain their multiplicity.

Go 1.23 selected for explicit edge IDs, adjacency and O(V+E) Hierholzer traversal. The independent Python reference uses exhaustive orientation/permutation backtracking for bounded graphs; it also validates edge multiset equality, continuity and closure. Alternative languages considered: Prolog for relation search, Ruby for expressive graph traversal.

Reproduce:
~~~sh
cd katas/KATA-000044
go test ./...
if go test -tags kata_red ./... >/tmp/domino-red.log 2>&1; then exit 1; fi
grep -q 'wrong possibility\|invalid chain' /tmp/domino-red.log
go build -o /tmp/domino-cli ./cmd/dominoes
python3 tests/differential.py /tmp/domino-cli
~~~

RED uses a compiled yet incorrect stub. GREEN: 10 named cases plus invalid pips and input immutability. Independent Python checks **952 scenarios**, including exhaustive small multisets, 650 random graphs, and 240 constructed Euler trails. Input negatives rejected; an impossible solution returns false and an empty chain.

Author-only provisional difficulty 5/5, rubric 93/100, not independently calibrated. A single kata cannot prove longitudinal learning or language superiority.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja observation](evidence/skill_review.md)
